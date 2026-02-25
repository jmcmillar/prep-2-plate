namespace :api do
  post "auth/sign_in", to: "auth#create"
  post "auth/sign_up", to: "auth_registration#create"
  delete "auth/sign_out", to: "auth#destroy"
  resource :home, only: [ :show ]
  resources :categories, only: %i[index], controller: "filters/categories"
  resources :meal_types, only: %i[index], controller: "filters/meal_types"
  resources :measurement_units, only: [ :index ]
  resources :recipes, only: [ :index, :show, :create, :update ]
  resources :recipe_ingredients, only: [ :index ]
  resource :recipe_imports, only: [ :show, :create ]
  resources :current_shopping_lists, only: [ :create ]
  resource :user_notifications, only: [ :update, :show ]
  resources :recipe_favorites, only: [ :index, :create ]
  resources :shopping_lists, only: [ :index, :create, :update, :destroy ] do
    resources :shopping_list_items, only: [ :index, :create, :update, :destroy ], shallow: true

    # Barcode lookup endpoint - RESTful show action
    resources :products, only: [:show], controller: "shopping_lists/products"
  end
  resource :export_meal_plans, only: [:create]
  resources :recipe_categories, only: [ :index, :show ]
  resource :user_details, only: %i[show update]
  resource :user_password, only: %i[update]
  resources :meal_plans, only: [ :index, :show, :create, :update, :destroy ]
  resources :user_meal_plans, only: [ :index, :create ]
  resources :user_ingredient_preferences, only: [ :index, :show, :create, :update, :destroy ] do
    collection do
      get :suggest
    end
  end
  resources :user_shopping_item_preferences, only: [ :index, :show, :create, :update, :destroy ] do
    collection do
      get :suggest
    end
  end
end
