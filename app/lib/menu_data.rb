class MenuData

  def self.admin_menu
    [
      MenuItemData[:admin_recipes, "Recipes", :admin_recipes, true],
      MenuItemData[:admin_recipe_categories, "Recipe Categories", :admin_recipe_categories, true],
      MenuItemData[:admin_ingredients, "Ingredients", :admin_ingredients, true],
      MenuItemData[:admin_ingredient_categories, "Ingredient Categories", :admin_ingredient_categories, true],
      MenuItemData[:admin_meal_plans, "Meal Plans", :admin_meal_plans, true],
      MenuItemData[:admin_meal_types, "Meal Types", :admin_meal_types, true],
      MenuItemData[:admin_measurement_units, "Measurement Units", :admin_measurement_units, true],
      MenuItemData[:admin_vendors, "Vendors", :admin_vendors, true],
      MenuItemData[:admin_resources, "Resources", :admin_resources, true],
      MenuItemData[:blazer, "Analytics", "/admin/blazer", true],
      MenuItemData[:admin_users, "Users", :admin_users, true]
    ]
  end

  def self.admin_user_menu(user)
    [
      MenuItemData[:back, "Admin", :admin_users, true],
      MenuItemData[:admin_user, "Overview", [:admin, user], true],
      MenuItemData[:admin_shopping_lists, "Shopping Lists", [:admin, user, :shopping_lists], true],
      MenuItemData[:admin_user_recipes, "Recipes", [:admin, user, :user_recipes], true]
    ]
  end

  def self.admin_vendor_menu(vendor)
    [
      MenuItemData[:back, "Admin", :admin_vendors, true],
      MenuItemData[:admin_vendor, "Overview", [:admin, vendor], true],
      MenuItemData[:admin_offerings, "Offerings", [:admin, vendor, :offerings], true]
    ]
  end


  def self.account_setting_menu
    [
      MenuItemData[:account_settings, "Account Settings", :account_profile, true],
      MenuItemData[:password, "Reset Password", :edit_account_password, true],
    ]
  end

  def self.main_menu
    [
      MenuItemData[:recipes, "Recipes", :recipes, true],
      MenuItemData[:meal_plans, "Free Meal Plans", :meal_plans, true],
      MenuItemData[:meal_prep, "Meal Prep", :vendors, true],
      MenuItemData[:resources, "Resources", :resources, true],
      MenuItemData[:meal_planner, "Build Your Own", :meal_planner, true],
    ]
  end

  class IconMap
    def self.to_h
      {
        admin_recipes: :salad,
        admin_meal_types: :utensils,
        admin_recipe_categories: :th_large,
        admin_ingredients: :list,
        admin_ingredient_categories: :tags,
        admin_measurement_units: :balance_scale,
        admin_meal_plans: :calendar,
        admin_vendors: :store,
        admin_offerings: :utensils,
        admin_users: :users,
        admin_shopping_lists: :shopping_cart,
        admin_user_recipes: :book,
        admin_resources: :file,
        blazer: :chart_bar,
        vendors: :store,
        back: :chevron_left
      }
    end
  end

  class Format
    NavFormat = Struct.new(:default, :active)
    def self.main_menu
      NavFormat[
        "font-bold tracking-wide uppercase mr-3",
        "font-bold tracking-wide uppercase mr-3 text-primary"
      ]
    end

    def self.admin_main_menu
      NavFormat[
        "flex items-center py-3 pl-4 text-gray-500 transition duration-150 ease-out hover:ease-in hover:bg-white hover:text-primary hover:font-bold",
        "flex items-center text-primary font-bold py-3 pl-4"
      ]
    end
  end
end
