class Components::ButtonLinkData < Struct.new(:label, :path, :icon, :scheme, :html_options, keyword_init: true) do
    def initialize(*)
      super
      self.scheme ||= :primary
      self.html_options ||= {}
    end
  end
end
