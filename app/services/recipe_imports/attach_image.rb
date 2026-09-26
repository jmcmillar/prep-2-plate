# Downloads a recipe image from a third-party URL and attaches it to a recipe.
# Uses the same SSRF-checked fetch as the page import, plus a size cap and an
# image content-type check. Failures are logged and never break the import.
class RecipeImports::AttachImage
  include Service

  MAX_BYTES = 10.megabytes
  DEFAULT_FILENAME = "recipe_image.jpg"

  def initialize(recipe, image_url, fetcher: Import::SafeFetch)
    @recipe = recipe
    @image_url = image_url
    @fetcher = fetcher
  end

  def call
    return false if @image_url.blank?

    attach(download)
    true
  rescue StandardError => e
    Rails.logger.warn("RECIPE_IMPORT: image not attached from #{@image_url}: #{e.message}")
    false
  end

  private

  def download
    response = @fetcher.get(@image_url)
    raise "not an image (#{content_type(response)})" unless content_type(response).start_with?("image/")
    raise "image larger than #{MAX_BYTES} bytes" if response.body.to_s.bytesize > MAX_BYTES

    response
  end

  def attach(response)
    @recipe.image.attach(
      io: StringIO.new(response.body),
      filename: filename,
      content_type: content_type(response)
    )
  end

  def content_type(response)
    response.headers["content-type"].to_s.split(";").first.to_s.strip
  end

  def filename
    File.basename(URI.parse(@image_url).path.to_s).presence || DEFAULT_FILENAME
  end
end
