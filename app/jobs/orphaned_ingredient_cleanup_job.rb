class OrphanedIngredientCleanupJob < ApplicationJob
  queue_as :default

  # Deletes ingredients nothing refers to. Recipes, offerings, shopping list
  # items (archived ones included) and learned user preferences all hold
  # foreign keys to ingredients, so any of them keeps an ingredient alive.
  def perform
    removed = orphaned_ingredients.destroy_all

    Rails.logger.info "OrphanedIngredientCleanupJob: Removed #{removed.size} orphaned ingredient(s)"
  end

  private

  def orphaned_ingredients
    referencing_ingredient_ids.reduce(Ingredient.where.missing(:recipe_ingredients)) do |scope, ids|
      scope.where.not(id: ids)
    end
  end

  def referencing_ingredient_ids
    [
      OfferingIngredient.select(:ingredient_id),
      ShoppingListItem.unscoped.where.not(ingredient_id: nil).select(:ingredient_id),
      UserIngredientPreference.select(:ingredient_id)
    ]
  end
end
