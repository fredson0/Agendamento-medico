class PacientesController < ApplicationController
  # registro é público
  skip_before_action :verify_authenticity_token, only: [:create]

  def new
    @paciente = Paciente.new
    @usuario = Usuario.new
  end

  def create
    ActiveRecord::Base.transaction do
      @usuario = Usuario.new(usuario_params.merge(papel: 'paciente'))
      if @usuario.save
        @paciente = Paciente.new(paciente_params)
        @paciente.usuario = @usuario
        if @paciente.save
          # auto login
          session[:usuario_id] = @usuario.id
          redirect_to minhas_consultas_path, notice: 'Cadastro realizado com sucesso.' and return
        else
          raise ActiveRecord::Rollback
        end
      else
        raise ActiveRecord::Rollback
      end
    end

    # se chegou aqui, falhou
    @paciente ||= Paciente.new(paciente_params)
    render :new, status: :unprocessable_entity
  end

  def minhas_consultas
    authenticate_usuario!
    unless current_usuario.papel == 'paciente'
      redirect_to root_path, alert: 'Apenas pacientes podem ver suas consultas.' and return
    end
    @paciente = current_usuario.paciente
    @consultas = Consulta.where(paciente: @paciente).order(inicio: :desc)
  end

  private

  def paciente_params
    params.fetch(:paciente, {}).permit(:nome, :cpf, :email, :telefone, :sexo, :data_nascimento)
  end

  def usuario_params
    params.fetch(:usuario, {}).permit(:username, :password, :password_confirmation)
  end
end
