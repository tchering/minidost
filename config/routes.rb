# frozen_string_literal: true

Rails.application.routes.draw do
  get "bios/show"
  get "bios/new"
  get "bios/create"
  get "bios/edit"
  get "bios/update"
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    devise_for :users, controllers: {}, sign_out_via: %i[get delete] # Add this option

    # Static pages routes
    get "contact", to: "static_pages#contact"
    get "blog", to: "static_pages#blog"
    get "help", to: "static_pages#help"
    get "about", to: "static_pages#about"

    # Add this line to see all routes
    # get "/routes", to: "rails/info/routes#index" if Rails.env.development?

    # Root route inside locale scope
    root "static_pages#home"

    resources :users, only: %i[show index] do
      member do
        get :map, to: "users#show_map" # create link to map_user_path(user)
      end
    end

    resources :bios, only: %i[show new create edit update]
    resources :tasks do
      collection do
        get :load_taskable_fields
        get :available_tasks
      end
      resources :task_applications, only: [:index, :new, :create, :destroy] do
        member do
          get :review
          post :approve
        end
      end
    end
  end

  # Health check route outside locale scope since it's for internal use
  get "up" => "rails/health#show", as: :rails_health_check
end
