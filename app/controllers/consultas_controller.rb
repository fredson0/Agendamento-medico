
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
      ['Realizada', 'realizada'],
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
    # Verificar se o usuário tem permissão para ver esta consulta
    unless can_view_consulta?(@consulta)
      redirect_to consultas_path, alert: 'Você não tem permissão para ver esta consulta.'
    end
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

  def edit
    @consulta = Consulta.find(params[:id])
    unless can_edit_consulta?(@consulta)
      redirect_to @consulta, alert: 'Você não tem permissão para editar esta consulta.'
      return
    end
    
    @medicos = Medico.includes(:usuario).where(ativo: true)
    @pacientes = Paciente.includes(:usuario).where(ativo: true)
    @unidades = Unidade.all
    @especialidades = Especialidade.all
    @salas = Sala.where(ativa: true)
  end

  def update
    @consulta = Consulta.find(params[:id])
    unless can_edit_consulta?(@consulta)
      redirect_to @consulta, alert: 'Você não tem permissão para editar esta consulta.'
      return
    end
    
    if @consulta.update(consulta_params)
      redirect_to @consulta, notice: 'Consulta atualizada com sucesso.'
    else
      @medicos = Medico.ativos
      @pacientes = Paciente.ativos
      @unidades = Unidade.all
      @especialidades = Especialidade.all
      @salas = Sala.where(ativa: true)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @consulta = Consulta.find(params[:id])
    
    unless can_delete_consulta?(@consulta)
      redirect_to consultas_path, alert: 'Você não tem permissão para deletar esta consulta.'
      return
    end
    
    unless @consulta.pode_ser_deletada?
      redirect_to @consulta, alert: 'Esta consulta não pode ser deletada. Apenas consultas agendadas e futuras podem ser removidas.'
      return
    end
    
    @consulta.destroy!
    redirect_to consultas_path, notice: 'Consulta deletada com sucesso.'
  end

  def historico
    case current_usuario.papel
    when 'paciente'
      @consultas = Consulta.historico_paciente(current_usuario.paciente)
      @titulo = 'Meu Histórico de Consultas'
    when 'medico'
      @consultas = Consulta.historico_medico(current_usuario.medico)
      @titulo = 'Histórico de Consultas Realizadas'
    else
      @consultas = Consulta.realizadas.includes(:paciente, :medico, :especialidade)
      @titulo = 'Histórico Geral de Consultas'
    end
  end

  def atualizar_status
    @consulta = Consulta.find(params[:id])
    
    unless can_update_status?(@consulta)
      redirect_to @consulta, alert: 'Você não tem permissão para atualizar o status desta consulta.'
      return
    end
    
    if @consulta.update(status_params)
      # Determinar mensagem de sucesso baseada no status
      message = case @consulta.status
                when 'confirmada'
                  'Consulta confirmada com sucesso!'
                when 'em_atendimento'
                  'Atendimento iniciado com sucesso!'
                when 'realizada'
                  'Consulta marcada como realizada!'
                when 'concluida'
                  'Consulta concluída com sucesso!'
                when 'cancelada'
                  'Consulta cancelada.'
                when 'no_show'
                  'Marcado como não compareceu.'
                else
                  'Status atualizado com sucesso!'
                end
      
      redirect_to edit_consulta_path(@consulta), notice: message
    else
      redirect_to edit_consulta_path(@consulta), alert: @consulta.errors.full_messages.join(', ')
    end
  end

  def realizar_atendimento
    @consulta = Consulta.find(params[:id])
    
    # Apenas médico responsável pode realizar atendimento
    unless current_usuario.papel == 'medico' && @consulta.medico.usuario == current_usuario
      redirect_to @consulta, alert: 'Apenas o médico responsável pode realizar o atendimento.'
      return
    end

    unless @consulta.pode_ser_realizada?
      redirect_to @consulta, alert: 'Esta consulta não pode ser realizada no momento.'
      return
    end
  end

  def finalizar_atendimento
    @consulta = Consulta.find(params[:id])
    
    # Apenas médico responsável pode finalizar atendimento
    unless current_usuario.papel == 'medico' && @consulta.medico.usuario == current_usuario
      redirect_to @consulta, alert: 'Apenas o médico responsável pode finalizar o atendimento.'
      return
    end

    @consulta.assign_attributes(historico_params)
    @consulta.status = 'realizada'
    @consulta.data_realizacao = Time.current

    if @consulta.save
      @consulta.gerar_comprovante_atendimento
      redirect_to @consulta, notice: 'Atendimento finalizado com sucesso! Comprovante gerado.'
    else
      render :realizar_atendimento, status: :unprocessable_entity
    end
  end

  private

  def consulta_params
    params.require(:consulta).permit(:paciente_id, :medico_id, :unidade_id, :sala_id, :especialidade_id, :inicio, :fim, :tipo, :status, :origem, :observacoes, :diagnostico, :prescricao, :observacoes_medicas, :procedimentos_realizados)
  end

  def status_params
    params.require(:consulta).permit(:status, :diagnostico, :prescricao, :observacoes_medicas, :procedimentos_realizados)
  end

  def historico_params
    params.require(:consulta).permit(:relatorio_medico, :receitas_medicamentos, :exames_solicitados, :proxima_consulta, :atestado_medico, :valor_pago)
  end

  def can_view_consulta?(consulta)
    case current_usuario.papel
    when 'admin', 'atendente'
      true
    when 'medico'
      consulta.medico.usuario == current_usuario
    when 'paciente'
      consulta.paciente.usuario == current_usuario
    else
      false
    end
  end

  def can_edit_consulta?(consulta)
    case current_usuario.papel
    when 'admin'
      true
    when 'atendente'
      consulta.status.in?(%w[marcada confirmada])
    when 'medico'
      consulta.medico.usuario == current_usuario && consulta.status.in?(%w[marcada confirmada em_atendimento])
    when 'paciente'
      consulta.paciente.usuario == current_usuario && consulta.status == 'marcada' && consulta.inicio > 24.hours.from_now
    else
      false
    end
  end

  def can_delete_consulta?(consulta)
    case current_usuario.papel
    when 'admin'
      true
    when 'atendente'
      consulta.pode_ser_deletada?
    when 'paciente'
      consulta.paciente.usuario == current_usuario && consulta.pode_ser_deletada? && consulta.inicio > 24.hours.from_now
    else
      false
    end
  end

  helper_method :can_view_consulta?, :can_edit_consulta?, :can_delete_consulta?, :can_update_status?

  def can_update_status?(consulta)
    case current_usuario.papel
    when 'admin', 'atendente'
      true
    when 'medico'
      consulta.medico.usuario == current_usuario
    else
      false
    end
  end

  def status_text(status)
    case status
    when 'marcada' then 'Marcada'
    when 'confirmada' then 'Confirmada'
    when 'em_atendimento' then 'Em Atendimento'
    when 'concluida' then 'Concluída'
    when 'realizada' then 'Realizada'
    when 'cancelada' then 'Cancelada'
    when 'no_show' then 'Não Compareceu'
    else status.humanize
    end
  end
end
