class CreateRecipeCategoryAssignments < ActiveRecord::Migration[7.2]
  def change
    create_table :recipe_category_assignments do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :recipe_category, null: false, foreign_key: true

      t.timestamps
    end
  end
end