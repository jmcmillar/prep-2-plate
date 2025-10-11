class Admin::RecipeInstructions::NewFacade < Base::Admin::NewFacade
  def recipe_instruction
    @instruction ||= recipe.recipe_instructions.new
  end

  def recipe
    @recipe ||= Recipe.find(@params[:recipe_id])
  end

  def active_key
    :admin_recipes
  end

  def measurement_units
    @measurement_units ||= MeasurementUnit.order(:name)
  end

  def instructions
    @instructions ||= Instruction.order(:name)
  end

  def breadcrumb_trail
    [
      BreadcrumbComponent::Data.new("Admin", [:admin, :recipes]),
      BreadcrumbComponent::Data.new("Recipe Instructions", [:admin, :recipe_instructions]),
      BreadcrumbComponent::Data.new("New")
    ]
  end

  def form_url
    [:admin, recipe, :recipe_instructions]
  end

  def cancel_path
    [:admin, recipe, :recipe_instructions]
  end
end
