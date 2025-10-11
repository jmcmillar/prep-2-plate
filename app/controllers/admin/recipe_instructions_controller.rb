class Admin::RecipeInstructionsController < AuthenticatedController
  def index
    @facade = Admin::RecipeInstructions::IndexFacade.new(Current.user, params)
  end

  def new
    @facade = Admin::RecipeInstructions::NewFacade.new(Current.user, params)
  end


  def create
    @facade = Admin::RecipeInstructions::NewFacade.new(Current.user, params)
    @facade.recipe_instruction.assign_attributes(instruction_params)
    if @facade.recipe_instruction.save
      redirect_to admin_recipe_recipe_instructions_url(@facade.recipe), notice: "Recipe Instruction was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @facade = Admin::RecipeInstructions::EditFacade.new(Current.user, params)
  end

  def update
    @facade = Admin::RecipeInstructions::EditFacade.new(Current.user, params)
    @facade.recipe_instruction.assign_attributes(instruction_params)
    if @facade.recipe_instruction.update(instruction_params)
      redirect_to admin_recipe_recipe_instructions_url(@facade.recipe), notice: "Recipe Instruction was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @facade = Admin::RecipeInstructions::DestroyFacade.new(Current.user, params)
    @facade.recipe_instruction.destroy
    set_destroy_flash_for(@facade.recipe_instruction)
  end

  private

  def instruction_params
    params.require(:recipe_instruction).permit(:step_number, :instruction)
  end
end
