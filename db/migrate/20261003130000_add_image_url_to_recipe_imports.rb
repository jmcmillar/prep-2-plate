class AddImageUrlToRecipeImports < ActiveRecord::Migration[8.0]
  def change
    add_column :recipe_imports, :image_url, :string
  end
end
