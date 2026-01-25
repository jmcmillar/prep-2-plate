require "test_helper"

class Clients::ResultTest < ActiveSupport::TestCase
  def setup
    @success = Clients::Result.new(data: {foo: "bar"}, success: true, error_message: nil)

    @failure = Clients::Result.new(data: nil, success: false, error_message: "Something went wrong")
  end

  def test_success_returns_true_when_success_is_true
    assert @success.success?
  end

  def test_success_returns_false_when_success_is_false
    refute @failure.success?
  end

  def test_failure_returns_false_when_success_is_true
    refute @success.failure?
  end

  def test_failure_returns_true_when_success_is_false
    assert @failure.failure?
  end

  def test_success_and_failure_are_opposites
    assert_equal @success.success?, !@success.failure?
    assert_equal @failure.success?, !@failure.failure?
  end
end
