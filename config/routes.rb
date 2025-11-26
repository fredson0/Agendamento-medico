Rails.application.routes.draw do
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Página inicial
  root to: 'dashboard#index'

  # Autenticação
  get '/login', to: 'sessions#new', as: :login
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: :logout

  # Registro de pacientes
  get '/registrar', to: 'pacientes#new', as: :registrar
  post '/registrar', to: 'pacientes#create'

  # Consultas de pacientes
  get '/minhas_consultas', to: 'pacientes#minhas_consultas', as: :minhas_consultas

  # Agendamento de consultas
  get '/agendamento', to: 'agendamentos#index', as: :agendamento
  get '/agendamento/medicos', to: 'agendamentos#medicos', as: :agendamento_medicos
  get '/agendamento/horarios', to: 'agendamentos#horarios', as: :agendamento_horarios
  get '/agendamento/confirmar', to: 'agendamentos#confirmar', as: :agendamento_confirmar
  post '/agendamentos', to: 'agendamentos#create', as: :agendamentos

  # Ajuda e suporte
  get '/ajuda', to: 'ajuda#index', as: :ajuda

  # Perfil do usuário
  get '/perfil', to: 'usuarios#perfil', as: :perfil
  patch '/perfil', to: 'usuarios#update_perfil'

  # API JWT
  scope '/auth', controller: :auth do
    post :login
    delete :logout
    get :me
  end
  
  # Endpoint de teste JWT (remover em produção)
  get '/auth/test/:username/:password', to: 'auth#test_login' if Rails.env.development?

  # Consultas
  resources :consultas do
    member do
      patch :atualizar_status
      get :realizar_atendimento
      patch :finalizar_atendimento
    end
  end
  
  # Histórico de consultas
  get '/historico', to: 'consultas#historico', as: :historico_consultas
end
