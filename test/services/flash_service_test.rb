require "test_helper"

class FlashServiceTest < ActiveSupport::TestCase
  def test_valid_alert
    flash_hash = ActionDispatch::Flash::FlashHash.new
    flash_hash[:alert] = "Something Bad!"
    flash_notice = FlashService.call(flash_hash)

    assert_kind_of ActiveSupport::SafeBuffer, flash_notice
  end

  def test_valid_notice
    flash_hash = ActionDispatch::Flash::FlashHash.new
    flash_hash[:notice] = "Something Good!"
    flash_notice = FlashService.call(flash_hash)

    assert_kind_of ActiveSupport::SafeBuffer, flash_notice
  end

  def test_nil_flash
    flash_hash = ActionDispatch::Flash::FlashHash.new
    flash_notice = FlashService.call(flash_hash)

    refute flash_notice
  end
end