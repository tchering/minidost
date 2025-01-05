# frozen_string_literal: true

Rails.application.routes.draw do
  # get "bios/show"
  # get "bios/new"
  # get "bios/create"
  # get "bios/edit"
  # get "bios/update"
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    devise_for :users, controllers: {}, sign_out_via: %i[get delete] # Add this option

    # Static pages routes
    get "contact", to: "static_pages#contact"
    get "blog", to: "static_pages#blog"
    get "help", to: "static_pages#help"
    get "about", to: "static_pages#about"
    get "team", to: "static_pages#team"

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
    resources :conversations, only: [:index, :create, :destroy] do
      member do
        get :chat
      end
      resources :messages, only: [:create] do
        collection do
          post :mark_as_read
        end
      end
    end
    resources :tasks do
      resources :contracts, only: [:new, :create, :show] do
        member do
          get :download
          post :sign_contract
        end
      end
      member do
        get :application_list
      end
      collection do
        get :load_taskable_fields
        get :available_tasks
      end
      resources :task_applications, only: [:index, :create, :destroy] do
        member do
          get :review_application
          post :approve_application
          post :reject_application
        end
      end
    end

    resources :notifications, only: [:index, :update] do
      collection do
        post :mark_all_as_read
      end
    end

    # Add this route to the existing routes
    get "users/profile", to: "users#profile"
  end

  # API routes
  namespace :api do
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"
    post "signup", to: "registrations#create"

    # Add profile route to API namespace
    get "users/profile", to: "users#profile"

    # Add project statistics route
    get "project_statistics", to: "project_statistics#index"

    # Add tasks routes
    get "tasks", to: "tasks#index"
    get "tasks/available", to: "tasks#available_tasks"
    get "tasks/:id", to: "tasks#show"
    resources :tasks do
      get 'available_tasks', on: :collection
      resources :task_applications, only: [:index, :show, :create, :update, :destroy]
      get 'my_application', to: 'task_applications#show_my_application'
      get 'applications', to: 'task_applications#index'
      get 'applications/:id', to: 'task_applications#show'
      post 'applications', to: 'task_applications#create'
      patch 'applications/:id', to: 'task_applications#update'
      delete 'applications/:id', to: 'task_applications#destroy'
    end
  end

  # Health check route outside locale scope since it's for internal use
  get "up" => "rails/health#show", as: :rails_health_check
end
