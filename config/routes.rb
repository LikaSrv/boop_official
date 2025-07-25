Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  mount StripeEvent::Engine, at: '/stripe-webhooks'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get 'à propos', to: 'pages#about', as: 'about'
  get 'privacy_policy', to: 'pages#privacy_policy', as: 'privacy_policy'
  get 'contact', to: 'pages#contact', as: 'contact'
  get 'terms', to: 'pages#terms', as: 'terms'
  get 'pourquoi-boop-pro', to: 'pages#why_boop_pro', as: 'why_boop_pro'
  get 'pourquoi-boop', to: 'pages#why_boop', as: 'why_boop'
  get 'explorer', to: 'professionals#index', as: 'explore'


  post 'professionals/duplicate', to: 'professionals#duplicate', as: 'duplicate_professional'
  get 'professionals/:id/edit_availibilities', to: 'professionals#edit_availibilities', as: 'professional_edit_availibilities'
  get 'closing_hours/check', to: 'closing_hours#check', as: 'check_closing_hour'

  resources :professionals, except: [:show] do
    resources :appointments, only: [:new, :create, :show]
    resources :reviews, only: [:new, :create]
    member do
      get :update_slots
      get :update_edit_slots
    end
    get 'pets/:id/show_for_pro', to: 'pets#show_for_pro', as: 'pet_show_for_pro'
  end

  get 'professionals/:id/:name', to: 'professionals#show', as: 'show_professional'

  resources :appointments, only: [:update]

  resources :closing_hours, only: [:new, :create, :destroy]

  resources :users do
    member do
      get 'professionals', to: 'professionals#pro_index', as: :pro_index
      get 'professionals/:professional_id', to: 'professionals#pro_show', as: :pro_show
    end
    resources :pets
  end

  resources :animals, only: [:index, :show]

  resources :pricings, only: [:index, :show]

  resources :orders, only: [:show, :create] do
    resources :payments, only: :new
  end

  resources :pets, only: [:show] do
    resources :vaccinations, only: [:new, :create, :destroy, :update]
    resources :weight_histories, only: [:new, :create, :destroy, :update]
  end

  resources :pet_alerts

  resources :posts, only: [:index, :show], param: :slug


end
