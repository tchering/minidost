# frozen_string_literal: true

Rails.application.routes.draw do
  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    devise_for :users

    # Static pages routes
    get 'contact', to: 'static_pages#contact'
    get 'blog', to: 'static_pages#blog'
    get 'help', to: 'static_pages#help'
    get 'about', to: 'static_pages#about'

    # Root route inside locale scope
    root 'static_pages#home'
  end

  # Health check route outside locale scope since it's for internal use
  get 'up' => 'rails/health#show', as: :rails_health_check
end
