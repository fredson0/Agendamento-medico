class AgendamentosController < ApplicationController
  before_action :authenticate_usuario!
  before_action :require_patient_role

  def index
    # Página inicial do agendamento - escolher especialidade
    @especialidades = Especialidade.joins(:medico_especialidades)
                                   .joins("INNER JOIN medicos ON medicos.id = medico_especialidades.medico_id")
                                   .where(medicos: { ativo: true })
                                   .distinct
                                   .order(:nome)
  end

  def medicos
    # Listar médicos da especialidade escolhida
    @especialidade_id = params[:especialidade_id]
    @especialidade = Especialidade.find(@especialidade_id) if @especialidade_id.present?
    
    if @especialidade
      @medicos = @especialidade.medicos.where(ativo: true).includes(:especialidades)
    else
      redirect_to agendamento_path, alert: 'Selecione uma especialidade primeiro.'
    end
  end

  def horarios
    # Mostrar horários disponíveis do médico escolhido
    @medico_id = params[:medico_id]
    @especialidade_id = params[:especialidade_id]
    @data_selecionada = params[:data].present? ? Date.parse(params[:data]) : Date.tomorrow
    
    @medico = Medico.find(@medico_id) if @medico_id.present?
    @especialidade = Especialidade.find(@especialidade_id) if @especialidade_id.present?
    
    if @medico.nil? || @especialidade.nil?
      redirect_to agendamento_path, alert: 'Dados incompletos. Reinicie o agendamento.'
      return
    end
    
    # Buscar agenda do médico
    @agenda = @medico.agendas.where(
      'data_inicio <= ? AND (data_fim IS NULL OR data_fim >= ?)',
      @data_selecionada, @data_selecionada
    ).first
    
    if @agenda
      # Buscar horários disponíveis para a data
      @horarios_disponiveis = buscar_horarios_disponiveis(@agenda, @data_selecionada)
    else
      @horarios_disponiveis = []
    end
  end

  def confirmar
    # Receber os parâmetros da URL
    @especialidade_id = params[:especialidade_id]
    @medico_id = params[:medico_id] 
    @data = params[:data]
    @horario_id = params[:horario_id]
    
    # Buscar os objetos no banco
    @especialidade = Especialidade.find(@especialidade_id) if @especialidade_id.present?
    @medico = Medico.find(@medico_id) if @medico_id.present?
    @horario = Horario.find(@horario_id) if @horario_id.present?
    @data_consulta = Date.parse(@data) if @data.present?
    
    # Validar se tudo existe
    if @especialidade.nil? || @medico.nil? || @horario.nil? || @data_consulta.nil?
      redirect_to agendamento_path, alert: 'Dados incompletos. Reinicie o agendamento.'
      return
    end
    
    # Informações adicionais para mostrar na tela
    @preco_consulta = 250.00
    @duracao_minutos = (@horario.fim - @horario.inicio) / 1.minute
  end

  def create
    # Buscar dados recebidos do formulário
    especialidade = Especialidade.find(params[:especialidade_id])
    medico = Medico.find(params[:medico_id])
    horario = Horario.find(params[:horario_id])
    
    # Verificar se o horário ainda está disponível
    unless horario.status == 'disponivel'
      redirect_to agendamento_path, alert: 'Horário não está mais disponível.'
      return
    end
    
    # Verificar se o paciente existe
    paciente = current_usuario.paciente
    unless paciente
      redirect_to agendamento_path, alert: 'Paciente não encontrado.'
      return
    end
    
    # Criar a consulta seguindo o padrão do sistema
    consulta = Consulta.new(
      paciente: paciente,
      medico: medico,
      unidade: medico.agendas.first&.unidade || Unidade.first,
      especialidade: especialidade,
      inicio: horario.inicio,
      fim: horario.fim,
      tipo: 'presencial',
      status: 'marcada',
      origem: 'app',
      observacoes: 'Agendamento realizado pelo paciente via sistema'
    )    
    # Tentar salvar a consulta
    if consulta.save
      # Marcar horário como reservado
      horario.update!(status: 'reservado')
      
      # Registrar auditoria da criação
      Auditoria.create!(
        acao: 'CREATE',
        entidade: 'consultas',
        id_registro: consulta.id,
        realizado_por: current_usuario.id,
        realizado_em: Time.current,
        diffs: { created: consulta.attributes }
      )
      
      redirect_to root_path, notice: 'Consulta agendada com sucesso!'
    else
      # Em caso de erro, mostrar detalhes e manter disponibilidade do horário
      error_messages = consulta.errors.full_messages.join(', ')
      Rails.logger.error "Erro ao salvar consulta: #{error_messages}"
      redirect_to agendamento_path, alert: "Erro ao agendar consulta: #{error_messages}"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to agendamento_path, alert: 'Dados inválidos para agendamento.'
  rescue StandardError => e
    Rails.logger.error "Erro ao criar consulta: #{e.message}"
    redirect_to agendamento_path, alert: 'Erro interno. Tente novamente.'
  end

  private

  def require_patient_role
    unless current_usuario.papel == 'paciente'
      redirect_to root_path, alert: 'Apenas pacientes podem acessar o agendamento.'
    end
  end

  def agendamento_params
    # Parâmetros permitidos para o agendamento
    params.permit(:especialidade_id, :medico_id, :data, :horario_id, :tipo)
  end

  def buscar_horarios_disponiveis(agenda, data)
    # Verificar se é um dia da semana que o médico atende
    dias_semana_map = {
      0 => 'SUN', 1 => 'MON', 2 => 'TUE', 3 => 'WED',
      4 => 'THU', 5 => 'FRI', 6 => 'SAT'
    }
    dia_semana = dias_semana_map[data.wday]
    return [] unless agenda.dias_semana&.include?(dia_semana)
    
    # Buscar horários já gerados para esta data
    horarios_existentes = agenda.horarios.where(
      'DATE(inicio) = ?', data
    ).where(status: 'disponivel')
    
    # Se não existem horários, gerar para esta data
    if horarios_existentes.empty?
      gerar_horarios_para_data(agenda, data)
      horarios_existentes = agenda.horarios.where(
        'DATE(inicio) = ?', data
      ).where(status: 'disponivel')
    end
    
    horarios_existentes.order(:inicio)
  end

  def gerar_horarios_para_data(agenda, data)
    # Gerar slots de horário para uma data específica
    hora_inicio = agenda.hora_inicio
    hora_fim = agenda.hora_fim
    duracao_slot = agenda.duracao_slot_min || 30
    
    horario_atual = Time.zone.parse("#{data} #{hora_inicio}")
    horario_fim = Time.zone.parse("#{data} #{hora_fim}")
    
    while horario_atual < horario_fim
      # Verificar se já existe consulta neste horário
      consulta_existente = Consulta.where(
        medico: agenda.medico,
        inicio: horario_atual,
        status: ['marcada', 'confirmada', 'em_atendimento']
      ).exists?
      
      unless consulta_existente
        agenda.horarios.create!(
          inicio: horario_atual,
          fim: horario_atual + duracao_slot.minutes,
          status: 'disponivel'
        )
      end
      
      horario_atual += duracao_slot.minutes
    end
  end
end