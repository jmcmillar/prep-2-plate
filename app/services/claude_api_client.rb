# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

# Client for interacting with Anthropic's Claude API
class ClaudeApiClient
  API_ENDPOINT = "https://api.anthropic.com/v1/messages"
  MODEL = "claude-sonnet-4-20250514"
  API_VERSION = "2023-06-01"
  MAX_TOKENS = 4096
  READ_TIMEOUT = 60

  def initialize(api_key: ENV.fetch("ANTHROPIC_API_KEY"))
    @api_key = api_key
  end

  # Send a prompt to Claude and get the response text
  # @param prompt [String] The prompt to send to Claude
  # @return [String] The response text from Claude
  def send_message(prompt)
    response = call_api(prompt)
    extract_content(response)
  end

  private

  attr_reader :api_key

  def call_api(prompt)
    uri = URI.parse(API_ENDPOINT)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = READ_TIMEOUT

    request = build_request(uri, prompt)
    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      raise "Claude API request failed: #{response.code} #{response.message}"
    end

    JSON.parse(response.body)
  end

  def build_request(uri, prompt)
    request = Net::HTTP::Post.new(uri.path)
    request["Content-Type"] = "application/json"
    request["x-api-key"] = api_key
    request["anthropic-version"] = API_VERSION
    
    request.body = JSON.generate({
      model: MODEL,
      max_tokens: MAX_TOKENS,
      messages: [{ role: "user", content: prompt }]
    })

    request
  end

  def extract_content(response)
    content = response.dig("content", 0, "text")
    raise "No content in Claude API response" if content.blank?
    
    content
  end
end
