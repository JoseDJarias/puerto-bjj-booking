Rails.application.routes.draw do
  resource :registration, only: %i[new create]
  resource :session
  resources :passwords, param: :token

  resources :class_schedules, only: [:show, :update] do
    member do
      get :participants 
    end
  end
  resources :bookings, only: [:create, :index]
  resource :user, only: [:show, :edit, :update], controller: 'users'
  get "mi-membresia/historial", to: "membership_info#history", as: :my_membership_history
  get "mi-membresia", to: "membership_info#show", as: :my_membership
  get "contacto", to: "contact#show", as: :contact
  get "dog-fights", to: "dog_fights#show", as: :dog_fights
  root "dashboard#show"

  namespace :admin do
    get "membership_pricings/index"
    get "dashboard/index", as: :dashboard

    resources :membership_plans, path: "planes"
    resources :class_types
    resources :membership_packages, path: "paquetes"
    resources :users do
      member do
        patch :approve #Generates: /admin/users/:id/approve
      end
      resources :drop_in_tickets, only: [:create, :destroy] do
        member do
          patch :void         # Block ticket access
          patch :reset_usage  # Reset to available
        end
      end
    end
    resources :memberships, path: "membresias" do
      collection do
        get :calculate_totals # This creates the route /admin/membresias/calculate_totals
      end
    end    
    resources :class_schedules do
      collection do
        # Routes for the bulk generator
        get :batch_new    # The "Generate Schedule" form
        post :process_batch # The action that creates the records
      end
      member do
        get :attendance
      end
    end
    resources :membership_pricings, path: 'precios'
      # Controller dedicated to the management of reservations by the admin
    resources :bookings, only: [:create, :update, :destroy] do
      member do
        patch :toggle_attendance
      end
    end
    resources :drop_in_tickets, only: [:create] do
      collection do
        delete :destroy_last
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
