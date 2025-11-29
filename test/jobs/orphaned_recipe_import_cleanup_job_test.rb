require "test_helper"

class OrphanedRecipeImportCleanupJobTest < ActiveJob::TestCase
  def test_removes_imports_not_associated_with_any_recipes
    orphaned_import = recipe_imports(:two)
    assert_not_nil orphaned_import

    OrphanedRecipeImportCleanupJob.perform_now

    assert_nil RecipeImport.find_by(id: orphaned_import.id)
  end

  def test_does_not_remove_imports_associated_with_recipes
    import_one = recipe_imports(:one)

    OrphanedRecipeImportCleanupJob.perform_now

    assert_not_nil RecipeImport.find_by(id: import_one.id)
  end
end
