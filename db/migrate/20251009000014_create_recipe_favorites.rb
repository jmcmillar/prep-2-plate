class CreateRecipeFavorites < ActiveRecord::Migration[7.2]
  def change
    create_table :recipe_favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true

      t.timestamps
    end
  end
end