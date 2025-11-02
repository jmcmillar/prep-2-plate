namespace :api do
  post "auth/sign_in", to: "auth#create"
  post "auth/sign_up", to: "auth_registration#create"
  delete "auth/sign_out", to: "auth#destroy"
  resource :home, only: [:show]
  resources :categories, only: %i[index], controller: "filters/categories"
  resources :measurement_units, only: [:index]
  resources :recipes, only: [:index, :show, :create]
  resources :recipe_ingredients, only: [:index]
  resource :recipe_imports, only: [:show, :create]
  resources :recipe_favorites, only: [:index, :create]
  resources :shopping_lists, only: [:index, :create, :destroy] do
    resources :shopping_list_items, only: [:index, :create, :destroy], shallow: true
  end
  resource :export_meal_plans, only: [:create]
  resources :recipe_categories, only: [:index, :show]
  resource :user_details, only: %i[show update]
  resource :user_password, only: %i[update]
  resources :meal_plans, only: [:create, :update, :destroy]
end
