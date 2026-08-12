Rails.application.routes.draw do
  root "static_pages#home"
  resource :session
  resource :sign_up

  resources :study_records, only: [ :new, :create, :show ] do
    member do
      patch :pause
      patch :resume
      patch :complete
    end

    resource :evaluation, only: [ :new, :create, :show ]
  end

  resources :histories, only: [ :index, :show ]

  get "up" => "rails/health#show", as: :rails_health_check
end
