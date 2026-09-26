# Fetches a recipe page and runs it through RecipeParser.
#
# Raises Import::SafeUrl::UnsafeUrlError (an ArgumentError) for disallowed
# URLs and ParseRecipe::FetchError when the page cannot be retrieved.
class ParseRecipe
  FetchError = Import::SafeFetch::FetchError

  def initialize(url, fetcher: Import::SafeFetch)
    @html = fetcher.get(url).body.to_s
  end

  def to_h
    RecipeParser.parse(@html).to_h
  end
end
