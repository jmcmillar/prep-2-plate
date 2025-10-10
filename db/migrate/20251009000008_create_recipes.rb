class CreateRecipes < ActiveRecord::Migration[7.2]
  def change
    create_table :recipes do |t|
      t.string :name
      t.references :recipe_import, null: true, foreign_key: true
      t.integer :serving_size
      t.integer :duration_minutes
      t.string :difficulty_level
      t.boolean :featured, default: false

      t.timestamps
    end
  end
end