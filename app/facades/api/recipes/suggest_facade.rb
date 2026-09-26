class Api::Recipes::SuggestFacade
  LIMIT = 8
  MIN_QUERY_LENGTH = 2

  def initialize(user, params)
    @user = user
    @params = params
  end

  # Catalog recipes plus the user's own; other users' recipes stay private.
  def recipes
    return Recipe.none if query.length < MIN_QUERY_LENGTH

    @recipes ||= Recipe.left_joins(:user_recipe)
      .where(user_recipes: { user_id: [ nil, @user.id ] })
      .trigram_search(query)
      .with_attached_image
      .limit(LIMIT)
  end

  private

  def query
    @query ||= @params[:q].to_s.squish
  end
end
