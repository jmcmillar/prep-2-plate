require "test_helper"

class Supports::ShowFacadeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @facade = Supports::ShowFacade.new(@user, {})
  end

  def test_active_key
    assert_equal :none, @facade.active_key
  end

  def test_support_email_defaults_when_env_not_set
    ENV.stub(:fetch, ->(_key, default) { default }) do
      assert_equal Supports::ShowFacade::DEFAULT_SUPPORT_EMAIL, @facade.support_email
    end
  end

  def test_faqs_have_questions_and_answers
    assert @facade.faqs.any?
    assert @facade.faqs.all? { |faq| faq.question.present? && faq.answer.present? }
  end
end
