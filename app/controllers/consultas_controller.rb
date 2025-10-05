
class ConsultasController < ApplicationController
  before_action :authenticate_usuario!
  before_action only: [:new, :create] do
    # permitir que admin, atendente ou o próprio paciente possam agendar
    if usuario_signed_in? && current_usuario.papel == 'paciente'
      # paciente pode criar para si mesmo
      true
    else
      require_roles(:admin, :atendente)
    end
  end

  def index
    # Médicos veem apenas suas consultas; outros veem todas
    if usuario_signed_in? && current_usuario.papel == 'medico'
      @consultas = Consulta.where(medico: current_usuario.medico).order(inicio: :desc)
    else
      @consultas = Consulta.order(inicio: :desc).limit(50)
    end
  end

  def show
    @consulta = Consulta.find(params[:id])
  end

  def new
    @consulta = Consulta.new
    @medicos = Medico.ativos
    @pacientes = Paciente.ativos
    @unidades = Unidade.all
    @especialidades = Especialidade.all
    @salas = Sala.where(ativa: true)
  end

  def create
    @consulta = Consulta.new(consulta_params)
    if @consulta.save
      redirect_to @consulta, notice: 'Consulta criada com sucesso.'
    else
      @medicos = Medico.ativos
      @pacientes = Paciente.ativos
      @unidades = Unidade.all
      @especialidades = Especialidade.all
      @salas = Sala.where(ativa: true)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def consulta_params
    params.require(:consulta).permit(:paciente_id, :medico_id, :unidade_id, :sala_id, :especialidade_id, :inicio, :fim, :tipo, :status, :origem, :observacoes)
  end
end
