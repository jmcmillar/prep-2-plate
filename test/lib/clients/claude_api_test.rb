require "test_helper"

class Clients::ClaudeApiTest < ActiveSupport::TestCase
  SCHEMA = { type: "object", properties: {}, additionalProperties: false }.freeze

  def test_defaults_to_existing_model_without_output_config
    body = Clients::ClaudeApi.new("hi", api_key: "key").send(:request_body)

    assert_equal Clients::ClaudeApi::MODEL, body[:model]
    assert_nil body[:output_config]
  end

  def test_accepts_model_and_structured_output_schema
    client = Clients::ClaudeApi.new("hi", api_key: "key", model: "claude-haiku-4-5", max_tokens: 100, output_schema: SCHEMA)
    body = client.send(:request_body)

    assert_equal "claude-haiku-4-5", body[:model]
    assert_equal 100, body[:max_tokens]
    assert_equal({ format: { type: "json_schema", schema: SCHEMA } }, body[:output_config])
  end

  def test_extracts_first_text_block
    response = { "stop_reason" => "end_turn", "content" => [ { "type" => "text", "text" => "{}" } ] }

    assert_equal "{}", Clients::ClaudeApi.new("hi", api_key: "key").send(:extract_content, response)
  end

  def test_refusal_and_truncation_are_errors
    %w[refusal max_tokens].each do |stop_reason|
      response = { "stop_reason" => stop_reason, "content" => [ { "type" => "text", "text" => "{" } ] }

      assert_raises(RuntimeError) { Clients::ClaudeApi.new("hi", api_key: "key").send(:extract_content, response) }
    end
  end
end
