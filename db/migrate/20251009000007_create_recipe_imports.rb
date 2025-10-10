class CreateRecipeImports < ActiveRecord::Migration[7.2]
  def change
    create_table :recipe_imports do |t|
      t.string :url

      t.timestamps
    end
  end
end