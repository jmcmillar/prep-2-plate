# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

# Client for interacting with Anthropic's Claude API
# Returns Result objects with AI-generated text responses
class Clients::ClaudeApi < Clients::BaseClient
    API_ENDPOINT = "https://api.anthropic.com/v1/messages"
    MODEL = "claude-sonnet-4-20250514"
    API_VERSION = "2023-06-01"
    MAX_TOKENS = 4096
    READ_TIMEOUT = 60
    CLIENT_NAME = "Claude API"

    def initialize(prompt, api_key: ENV.fetch("ANTHROPIC_API_KEY"))
      @prompt = prompt
      @api_key = api_key
    end

    def call
      response = make_api_request
      parsed = JSON.parse(response.body)
      content = extract_content(parsed)

      success_result(content)
    rescue StandardError => e
      error_result(
        "An error occurred while calling Claude API: #{e.message}",
        log_prefix: "CLAUDE_API"
      )
    end

    private

    def make_api_request
      uri = URI.parse(API_ENDPOINT)
      http = http_client(uri, read_timeout: READ_TIMEOUT)
      request = build_request(uri)
      response = http.request(request)

      validate_response!(response, client_name: CLIENT_NAME)
      response
    end

    def build_request(uri)
      request = Net::HTTP::Post.new(uri.path)
      request["Content-Type"] = "application/json"
      request["x-api-key"] = @api_key
      request["anthropic-version"] = API_VERSION

      request.body = JSON.generate({
        model: MODEL,
        max_tokens: MAX_TOKENS,
        messages: [{ role: "user", content: @prompt }]
      })

      request
    end

    def extract_content(response)
      content = response.dig("content", 0, "text")
      raise "No content in Claude API response" if content.blank?

      content
    end
end
