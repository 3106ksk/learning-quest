Rails.application.routes.draw do
  get "home", to: "home#index", as: :home
  root "static_pages#home"
  resource :session
  resources :passwords, param: :token
  resource :sign_up

  resources :study_records, only: [ :index, :new, :create, :show, :update, :destroy ] do
    member do
      patch :pause
      patch :resume
    end
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
