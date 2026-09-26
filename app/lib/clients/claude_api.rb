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

    # @param model [String] Model ID; defaults to MODEL
    # @param output_schema [Hash, nil] JSON schema to constrain the response
    #   (structured outputs); the returned text is then guaranteed-valid JSON
    def initialize(prompt, api_key: ENV.fetch("ANTHROPIC_API_KEY"), model: MODEL, max_tokens: MAX_TOKENS, output_schema: nil)
      @prompt = prompt
      @api_key = api_key
      @model = model
      @max_tokens = max_tokens
      @output_schema = output_schema
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

      request.body = JSON.generate(request_body)

      request
    end

    def request_body
      body = {
        model: @model,
        max_tokens: @max_tokens,
        messages: [ { role: "user", content: @prompt } ]
      }
      body[:output_config] = { format: { type: "json_schema", schema: @output_schema } } if @output_schema
      body
    end

    def extract_content(response)
      stop_reason = response["stop_reason"]
      raise "Claude API stopped early: #{stop_reason}" if %w[refusal max_tokens].include?(stop_reason)

      content = response["content"]&.find { |block| block["type"] == "text" }&.dig("text")
      raise "No content in Claude API response" if content.blank?

      content
    end
end
