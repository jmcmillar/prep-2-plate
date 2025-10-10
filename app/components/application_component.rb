class ApplicationComponent < ViewComponent::Base
  # include Ransack::Helpers::FormHelper

  private

  HTML_OPTION_KEYS = %i[class data aria style id]

  def extract_html_from_options(options = {}, key_list = HTML_OPTION_KEYS)
    options.select { |key, _| key_list.include? key }
  end
end
