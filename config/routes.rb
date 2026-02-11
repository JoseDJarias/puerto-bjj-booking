Rails.application.routes.draw do
  root "dashboard#show"

  resource :registration, only: %i[new create]
  resource :session
  resources :passwords, param: :token

  resources :class_schedules, only: [:index] 
  resources :bookings, only: [:create]

  namespace :admin do
    root "dashboard#index"

    resources :membership_plans, path: "planes"
    resources :class_types
    resources :membership_packages, path: "paquetes"
    resources :users do
      member do
        patch :approve #Generates: /admin/users/:id/approve
      end
    end
    resources :memberships, path: "membresias"
    resources :class_schedules do
      collection do
        # Routes for the bulk generator
        get :batch_new    # The "Generate Schedule" form
        post :batch_create # The action that creates the records
      end
    end
      # Controller dedicated to the management of reservations by the admin
    resources :bookings, only: [:create, :update, :destroy] do
      member do
        patch :check_in # Route to mark attendance quickly
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
