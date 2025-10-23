require "test_helper"

class FlashServiceTest < ViewComponent::TestCase
  def test_valid_alert
    with_controller_class ApplicationController do
      controller.flash[:alert] = "Something Bad!"
      flash_notice = FlashService.call(controller.flash)
      flash_notice.tap { |flash|
        assert_kind_of ActionView::OutputBuffer, flash
      }
    end
  end

  def test_valid_notice
    with_controller_class ApplicationController do
      controller.flash[:notice] = "Something Good!"
      flash_notice = FlashService.call(controller.flash)
      flash_notice.tap { |flash|
        assert_kind_of ActionView::OutputBuffer, flash
      }
    end
  end

  def test_nil_flash
    with_controller_class ApplicationController do
      flash_notice = FlashService.call(controller.flash)
      refute flash_notice
    end
  end
end