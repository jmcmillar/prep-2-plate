class CreateRecipeInstructions < ActiveRecord::Migration[7.2]
  def change
    create_table :recipe_instructions do |t|
      t.references :recipe, null: false, foreign_key: true
      t.integer :step_number, null: false
      t.text :instruction, null: false

      t.timestamps
    end
  end
end