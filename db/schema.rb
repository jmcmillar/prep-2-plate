# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_12_18_003715) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ingredient_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "ingredient_category_id"
    t.string "categorized_by"
    t.datetime "categorized_at"
    t.string "packaging_form"
    t.string "preparation_style"
    t.index ["ingredient_category_id"], name: "index_ingredients_on_ingredient_category_id"
    t.index ["name", "packaging_form", "preparation_style"], name: "idx_ingredients_on_name_packaging_prep", unique: true
  end

  create_table "meal_plan_recipes", force: :cascade do |t|
    t.bigint "meal_plan_id", null: false
    t.bigint "recipe_id", null: false
    t.integer "day_sequence"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meal_plan_id"], name: "index_meal_plan_recipes_on_meal_plan_id"
    t.index ["recipe_id"], name: "index_meal_plan_recipes_on_recipe_id"
  end

  create_table "meal_plans", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "featured", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meal_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "measurement_unit_aliases", force: :cascade do |t|
    t.bigint "measurement_unit_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["measurement_unit_id"], name: "index_measurement_unit_aliases_on_measurement_unit_id"
  end

  create_table "measurement_units", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recipe_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recipe_category_assignments", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "recipe_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_category_id"], name: "index_recipe_category_assignments_on_recipe_category_id"
    t.index ["recipe_id"], name: "index_recipe_category_assignments_on_recipe_id"
  end

  create_table "recipe_favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "recipe_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_recipe_favorites_on_recipe_id"
    t.index ["user_id", "recipe_id"], name: "index_recipe_favorites_on_user_and_recipe", unique: true
    t.index ["user_id"], name: "index_recipe_favorites_on_user_id"
  end

  create_table "recipe_imports", force: :cascade do |t|
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "ingredient_id", null: false
    t.bigint "measurement_unit_id"
    t.text "notes"
    t.integer "numerator"
    t.integer "denominator"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "quantity", type: :decimal, as: "\nCASE\n    WHEN (denominator <> 0) THEN ((numerator)::numeric / (denominator)::numeric)\n    ELSE NULL::numeric\nEND", stored: true
    t.index ["ingredient_id"], name: "index_recipe_ingredients_on_ingredient_id"
    t.index ["measurement_unit_id"], name: "index_recipe_ingredients_on_measurement_unit_id"
    t.index ["recipe_id"], name: "index_recipe_ingredients_on_recipe_id"
  end

  create_table "recipe_instructions", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.integer "step_number", null: false
    t.text "instruction", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_recipe_instructions_on_recipe_id"
  end

  create_table "recipe_meal_types", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "meal_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meal_type_id"], name: "index_recipe_meal_types_on_meal_type_id"
    t.index ["recipe_id"], name: "index_recipe_meal_types_on_recipe_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.string "name"
    t.bigint "recipe_import_id"
    t.integer "serving_size"
    t.integer "duration_minutes"
    t.string "difficulty_level"
    t.boolean "featured", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_recipes_on_created_at"
    t.index ["duration_minutes"], name: "index_recipes_on_duration_minutes"
    t.index ["featured"], name: "index_recipes_on_featured"
    t.index ["recipe_import_id"], name: "index_recipes_on_recipe_import_id"
  end

  create_table "resources", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.datetime "expires_at"
    t.datetime "last_used_at"
    t.index ["token"], name: "index_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "shopping_list_items", force: :cascade do |t|
    t.string "name"
    t.bigint "shopping_list_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shopping_list_id"], name: "index_shopping_list_items_on_shopping_list_id"
  end

  create_table "shopping_lists", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.boolean "current", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shopping_list_items_count", default: 0, null: false
    t.index ["current"], name: "index_shopping_lists_on_current"
    t.index ["user_id", "current"], name: "index_shopping_lists_on_user_id_and_current"
    t.index ["user_id"], name: "index_shopping_lists_on_user_id"
  end

  create_table "user_meal_plans", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "meal_plan_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meal_plan_id"], name: "index_user_meal_plans_on_meal_plan_id"
    t.index ["user_id"], name: "index_user_meal_plans_on_user_id"
  end

  create_table "user_recipes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "recipe_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_user_recipes_on_recipe_id"
    t.index ["user_id", "recipe_id"], name: "index_user_recipes_on_user_and_recipe", unique: true
    t.index ["user_id"], name: "index_user_recipes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.string "first_name"
    t.string "last_name"
    t.boolean "notifications", default: false, null: false
    t.boolean "reminders", default: false, null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "ingredients", "ingredient_categories"
  add_foreign_key "meal_plan_recipes", "meal_plans"
  add_foreign_key "meal_plan_recipes", "recipes"
  add_foreign_key "measurement_unit_aliases", "measurement_units"
  add_foreign_key "recipe_category_assignments", "recipe_categories"
  add_foreign_key "recipe_category_assignments", "recipes"
  add_foreign_key "recipe_favorites", "recipes"
  add_foreign_key "recipe_favorites", "users"
  add_foreign_key "recipe_ingredients", "ingredients"
  add_foreign_key "recipe_ingredients", "measurement_units"
  add_foreign_key "recipe_ingredients", "recipes"
  add_foreign_key "recipe_instructions", "recipes"
  add_foreign_key "recipe_meal_types", "meal_types"
  add_foreign_key "recipe_meal_types", "recipes"
  add_foreign_key "recipes", "recipe_imports"
  add_foreign_key "sessions", "users"
  add_foreign_key "shopping_list_items", "shopping_lists"
  add_foreign_key "shopping_lists", "users"
  add_foreign_key "user_meal_plans", "meal_plans"
  add_foreign_key "user_meal_plans", "users"
  add_foreign_key "user_recipes", "recipes"
  add_foreign_key "user_recipes", "users"

  create_view "meal_plan_ingredients", sql_definition: <<-SQL
      WITH ingredient_unit_totals AS (
           SELECT meal_plans.id AS meal_plan_id,
              ingredients.name,
              recipe_ingredients.ingredient_id,
              measurement_units.name AS unit_name,
              sum((recipe_ingredients.quantity)::double precision) AS quantity,
              sum(
                  CASE
                      WHEN (recipe_ingredients.denominator = 0) THEN (0)::double precision
                      ELSE ((recipe_ingredients.numerator)::double precision / (recipe_ingredients.denominator)::double precision)
                  END) AS total_amount
             FROM ((((meal_plans
               LEFT JOIN meal_plan_recipes ON ((meal_plan_recipes.meal_plan_id = meal_plans.id)))
               LEFT JOIN recipe_ingredients ON ((meal_plan_recipes.recipe_id = recipe_ingredients.recipe_id)))
               JOIN ingredients ON ((recipe_ingredients.ingredient_id = ingredients.id)))
               LEFT JOIN measurement_units ON ((recipe_ingredients.measurement_unit_id = measurement_units.id)))
            GROUP BY meal_plans.id, recipe_ingredients.ingredient_id, measurement_units.name, ingredients.name
          )
   SELECT ingredient_unit_totals.meal_plan_id,
      ingredient_unit_totals.ingredient_id,
      ingredient_unit_totals.unit_name,
      ingredient_unit_totals.name,
      ingredient_unit_totals.quantity,
          CASE
              WHEN (ingredient_unit_totals.total_amount = (0)::double precision) THEN ''::text
              WHEN (floor(ingredient_unit_totals.total_amount) = ingredient_unit_totals.total_amount) THEN ((ingredient_unit_totals.total_amount)::integer)::text
              ELSE
              CASE
                  WHEN (floor(ingredient_unit_totals.total_amount) = (0)::double precision) THEN ( WITH frac AS (
                           SELECT (round((ingredient_unit_totals.total_amount * (24)::double precision)))::integer AS num,
                              24 AS denom
                          ), reduced AS (
                           SELECT (frac.num / gcd(frac.num, frac.denom)) AS n,
                              (frac.denom / gcd(frac.num, frac.denom)) AS d
                             FROM frac
                          )
                   SELECT ((reduced.n || '/'::text) || reduced.d)
                     FROM reduced)
                  ELSE ( WITH frac AS (
                           SELECT (round(((ingredient_unit_totals.total_amount - floor(ingredient_unit_totals.total_amount)) * (24)::double precision)))::integer AS num,
                              24 AS denom
                          ), reduced AS (
                           SELECT (frac.num / gcd(frac.num, frac.denom)) AS n,
                              (frac.denom / gcd(frac.num, frac.denom)) AS d
                             FROM frac
                          )
                   SELECT (((((floor(ingredient_unit_totals.total_amount))::text || ' '::text) || reduced.n) || '/'::text) || reduced.d)
                     FROM reduced)
              END
          END AS formatted_amount
     FROM ingredient_unit_totals
    ORDER BY ingredient_unit_totals.meal_plan_id, ingredient_unit_totals.name;
  SQL
end
