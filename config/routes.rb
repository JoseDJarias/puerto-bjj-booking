Rails.application.routes.draw do
  root "dashboard#show"

  resource :registration, only: %i[new create]
  resource :session
  resources :passwords, param: :token

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
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
