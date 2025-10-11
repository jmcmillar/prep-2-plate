class Admin::RecipeInstructions::DestroyFacade < Base::Admin::DestroyFacade
  def recipe_instruction
    @recipe_instruction ||= RecipeInstruction.find(@params[:id])
  end
end
