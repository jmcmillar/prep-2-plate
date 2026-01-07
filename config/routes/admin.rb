get 'admin/recipes_exports', to: 'admin/recipe_exports#export_file',  defaults: { format: :ics }

# Mount Blazer for business intelligence queries
mount Blazer::Engine, at: "admin/blazer"

namespace :admin do
  get 'analytics/shopping_lists', to: 'analytics#shopping_lists'
  get 'analytics/user_preferences', to: 'analytics#user_preferences'

  resources :resources, except: :show
  resources :recipe_exports, only: :create
  resources :recipes, shallow: true do
    resources :import_ingredients, controller: "recipe_imports/ingredients", only: [:new, :create]
    resources :recipe_ingredients, except: :show, shallow: true
    resources :recipe_instructions, except: :show, shallow: true
  end
  resources :recipe_imports, only: [:new, :create] do
    resources :recipe_import_steps
    resources :recipes, controller: "recipe_imports/recipes", only: [:new, :create]
  end
  resources :meal_plans, shallow: true do
    resources :meal_plan_exports, only: [:new, :create]
    resources :meal_plan_exports, only: :index, defaults: { format: :ics }
    resources :meal_plan_recipes, shallow: true, except: :show
    resources :meal_plan_ingredients, shallow: true, except: :show
  end
  resources :meal_types, except: :show
  resources :recipe_categories, except: :show
  resources :ingredient_categories, except: :show
  resources :ingredients do
    resources :recipes, only: :index, controller: "ingredients/recipes"
  end
  resources :shopping_lists do
    resources :shopping_list_items, except: :show
  end
  resources :measurement_units do
    resources :measurement_unit_aliases, except: :show, shallow: true
  end
  resources :users, except: :destroy do
    resources :user_analytics, only: [:index]
    resources :user_recipes, shallow: true, except: [:new, :create]
    resources :shopping_lists, shallow: true do
      resources :shopping_list_items, except: :show, shallow: true
    end
    resources :user_meal_plans, only: [:index, :show, :destroy], shallow: true do
      resources :user_meal_plan_recipes, shallow: true, only: [:index, :destroy]
    end
  end
  resources :vendors do
    resources :offerings, shallow: true do
      resources :offering_ingredients, except: :show, shallow: true
    end
  end
end
