class UserIngredientPreferences::NewFacade < BaseFacade
  def preference
    @preference ||= UserIngredientPreference.new(user: @user)
  end

  def ingredients
    @ingredients ||= Ingredient.order(:name).pluck(:name, :id)
  end

  def packaging_options
    [["Any", ""]] + Ingredient::PACKAGING_FORMS.map { |key, value| [value, key.to_s] }
  end

  def preparation_options
    [["Any", ""]] + Ingredient::PREPARATION_STYLES.map { |key, value| [value, key.to_s] }
  end

  def form_url
    {
      controller: "user_ingredient_preferences",
      action: "create"
    }
  end

  def cancel_path
    {
      controller: "user_ingredient_preferences",
      action: "index"
    }
  end

  def active_key
    :none
  end
end
