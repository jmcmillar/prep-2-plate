class Admin::RecipeInstructions::EditFacade < Base::Admin::EditFacade
  def recipe_instruction
    @recipe_instruction ||= RecipeInstruction.find(@params[:id])
  end

  def recipe
    recipe_instruction.recipe
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
      BreadcrumbComponent::Data.new("Edit")
    ]
  end

  def form_url
    [:admin, recipe_instruction]
  end

  def cancel_path
    [:admin, recipe, :recipe_instructions]
  end
end
