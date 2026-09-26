# Suggests ingredient names for a recipe ingredient line as it is typed.
# `q` is the whole line ("2 cups fl"); only the name part is searched.
class Api::Ingredients::SuggestFacade
  LIMIT = 8
  MIN_FRAGMENT_LENGTH = 2

  def initialize(params)
    @params = params
  end

  def fragment
    @fragment ||= ParseIngredient.new(@params[:q].to_s).name_fragment
  end

  # Several ingredients share a name across packaging/preparation variants,
  # so fetch extra rows and dedupe by name.
  def names
    return [] if fragment.to_s.length < MIN_FRAGMENT_LENGTH

    @names ||= Ingredient.trigram_search(fragment).limit(LIMIT * 3).pluck(:name).uniq.first(LIMIT)
  end
end
