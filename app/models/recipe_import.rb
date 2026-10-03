class RecipeImport < ApplicationRecord
  has_many :recipes, class_name: "Recipe", foreign_key: "recipe_import_id"

  validates :url, presence: true, uniqueness: { case_sensitive: false }
  validates :url, https_url: true

  # The source page's image, linked rather than copied into storage. Only
  # https links are kept (the app can't load plain http images), upgrading
  # http ones since most sites serve both.
  def image_url=(value)
    uri = URI.parse(value.to_s.strip)
    uri.scheme = "https" if uri.scheme == "http"
    super(uri.is_a?(URI::HTTP) && uri.host.present? ? uri.to_s : nil)
  rescue URI::InvalidURIError
    super(nil)
  end
end
