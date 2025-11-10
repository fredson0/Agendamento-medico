
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
    # Base da consulta - médicos veem apenas suas consultas; outros veem todas
    consultas_base = if usuario_signed_in? && current_usuario.papel == 'medico'
      Consulta.where(medico: current_usuario.medico)
    else
      Consulta.all
    end

    # Aplicar filtros
    consultas_base = consultas_base.includes(:paciente, :medico, :unidade, :especialidade, :sala)
    
    # Filtro por status
    if params[:status].present? && params[:status] != 'todos'
      consultas_base = consultas_base.where(status: params[:status])
    end
    
    # Filtro por médico (apenas para admin/atendente)
    if params[:medico_id].present? && params[:medico_id] != 'todos' && 
       (current_usuario.papel == 'admin' || current_usuario.papel == 'atendente')
      consultas_base = consultas_base.where(medico_id: params[:medico_id])
    end
    
    # Filtro por período
    if params[:data_inicio].present?
      consultas_base = consultas_base.where('inicio >= ?', Date.parse(params[:data_inicio]))
    end
    
    if params[:data_fim].present?
      consultas_base = consultas_base.where('inicio <= ?', Date.parse(params[:data_fim]).end_of_day)
    end
    
    # Filtro por tipo
    if params[:tipo].present? && params[:tipo] != 'todos'
      consultas_base = consultas_base.where(tipo: params[:tipo])
    end

    # Ordenação
    @consultas = consultas_base.order(inicio: :desc).limit(100)
    
    # Dados para os filtros
    @medicos = if current_usuario.papel == 'admin' || current_usuario.papel == 'atendente'
      Medico.ativos.order(:nome)
    else
      []
    end
    
    @status_options = [
      ['Todos', 'todos'],
      ['Marcada', 'marcada'],
      ['Confirmada', 'confirmada'],
      ['Em Atendimento', 'em_atendimento'],
      ['Concluída', 'concluida'],
      ['Cancelada', 'cancelada'],
      ['Não Compareceu', 'no_show']
    ]
    
    @tipo_options = [
      ['Todos', 'todos'],
      ['Presencial', 'presencial'],
      ['Teleconsulta', 'teleconsulta']
    ]
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
