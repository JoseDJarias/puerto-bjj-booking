Rails.application.routes.draw do
  root "dashboard#show"

  resource :registration, only: %i[new create]
  resource :session
  resources :passwords, param: :token

  get "up" => "rails/health#show", as: :rails_health_check
end
