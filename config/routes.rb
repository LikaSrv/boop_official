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
  post 'professionals/duplicate', to: 'professionals#duplicate', as: 'duplicate_professional'
  get 'professionals/:id/edit_slots', to: 'professionals#edit_slots', as: 'professional_edit_slots'
  get 'professionals/:id/update_slots', to: 'professionals#update_slots', as: 'professional_update_slots'

    # autres routes...

  # Defines the root path route ("/")
  # root "posts#index"

  resources :professionals do
    resources :appointments, only: [:new, :create, :show]
    resources :reviews, only: [:new, :create]
  end

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

end
