Rails.application.routes.draw do
  # Devise handles authentication routes: /users/sign_in, /users/sign_up, /users/password, etc.
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
    get "up" => "rails/health#show", as: :rails_health_check
  mount MissionControl::Jobs::Engine, at: "/jobs"

  # Letter opener web interface for viewing emails in development
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root 'public#index'
  resources :recipes, only: %i[index show] do
    resources :recipe_favorites, only: %i[create destroy], shallow: true
  end
  resources :my_recipes, only: %i[index]
  resources :user_recipes, only: %i[new create edit update destroy], shallow: true
  resources :user_recipe_imports, only: %i[new create]
  resources :meal_plans, only: %i[index show] do
    resource :export_to_shopping_list, only: [:new, :create], controller: 'meal_plans/export_to_shopping_lists'
  end
  resources :shopping_lists, only: [:index, :new, :create, :update, :show, :destroy] do
    resources :items, except: [:show], controller: "shopping_list_items", shallow: true
  end
  resource :meal_planner, only: [:show]

  namespace :meal_planner do
    resource :export_to_shopping_list, only: [:new, :create]
    resources :recipes, only: %i[index create destroy]
    resources :calendar_exports, only: [:new]
    resources :calendar_exports, only: [:create], default: { format: :ics }
  end
  namespace :account do
    resource :profile, only: %i[show edit update]
    resource :password, only: %i[edit update]
  end
  resources :resources, only: %i[index]
  resources :table_actions, only: :index
  resource :terms_of_service, only: :show
  resource :about, only: :show
  draw "admin"
  draw "api"
end
