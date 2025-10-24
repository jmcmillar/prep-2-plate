Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
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
    resources :recipes, only: %i[index show]
  resources :user_recipes, only: %i[new create edit update destroy]
  resources :meal_plans, only: %i[index show] do
    resource :export_to_shopping_list, only: [:new, :create], controller: 'meal_plans/export_to_shopping_lists'
  end
  resources :shopping_lists, only: [:index, :create, :update, :show, :destroy] do
    resources :items, only: [:create], controller: "shopping_list_items"
  end
  resource :meal_planner, only: [:show]

  post "/meal_planners/notes", to: "meal_planners#update_note"
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
end
