Rails.application.routes.draw do
  # Rotas principais definidas abaixo (removidas rotas geradas redundantes)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root to: 'dashboard#index'

  get '/login', to: 'sessions#new', as: :login
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: :logout

  # Registro de pacientes (página pública)
  get '/registrar', to: 'pacientes#new', as: :registrar
  post '/registrar', to: 'pacientes#create'

  # Rotas para pacientes verem suas consultas
  get '/minhas_consultas', to: 'pacientes#minhas_consultas', as: :minhas_consultas

  # dashboard via root
  resources :consultas, only: [:index, :show, :new, :create]
  
  # Sistema de agendamento de consultas
  resources :agendamentos, only: [:index] do
    collection do
      get :medicos
      get :horarios
      get :confirmar
      post :create
    end
  end
end
