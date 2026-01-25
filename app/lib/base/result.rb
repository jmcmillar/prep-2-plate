# frozen_string_literal: true

# Shared immutable result object for services and API clients
# Provides consistent interface for success/failure states across the application
class Base::Result
  attr_reader :data, :success, :error_message

  def initialize(data:, success:, error_message:)
    @data = data
    @success = success
    @error_message = error_message
    freeze
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end
