require "test_helper"

class RecipeImports::AttachImageTest < ActiveSupport::TestCase
  Response = Struct.new(:headers, :body)

  class FakeFetcher
    def initialize(response = nil, error: nil)
      @response = response
      @error = error
    end

    def get(_url)
      raise @error if @error

      @response
    end
  end

  PNG = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==")

  def setup
    @recipe = Recipe.new(name: "Imaged")
  end

  def test_attaches_image
    fetcher = FakeFetcher.new(Response.new({ "content-type" => "image/png" }, PNG))

    assert attach("https://example.com/img/pie.png", fetcher)
    assert @recipe.image.attached?
    assert_equal "pie.png", @recipe.image.filename.to_s
  end

  def test_skips_non_images
    fetcher = FakeFetcher.new(Response.new({ "content-type" => "text/html; charset=utf-8" }, "<html>"))

    assert_not attach("https://example.com/page", fetcher)
    assert_not @recipe.image.attached?
  end

  def test_skips_oversized_images
    fetcher = FakeFetcher.new(Response.new({ "content-type" => "image/jpeg" }, "x" * (RecipeImports::AttachImage::MAX_BYTES + 1)))

    assert_not attach("https://example.com/huge.jpg", fetcher)
  end

  def test_fetch_errors_do_not_raise
    fetcher = FakeFetcher.new(error: Import::SafeUrl::UnsafeUrlError.new("private"))

    assert_not attach("http://169.254.169.254/", fetcher)
  end

  def test_blank_url_is_skipped
    assert_not attach(nil, FakeFetcher.new)
  end

  private

  def attach(url, fetcher)
    RecipeImports::AttachImage.call(@recipe, url, fetcher: fetcher)
  end
end
