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
      redirect_to agendamento_path, alert: 'Especialidade não encontrada.'
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

    # Verificar se o horário ainda está disponível
    unless @horario.status == 'disponivel'
      redirect_to agendamento_horarios_path(especialidade_id: @especialidade_id, medico_id: @medico_id, data: @data),
                  alert: 'Este horário não está mais disponível.'
      return
    end

    # Calcular duração e preço (valores padrão se não definidos)
    @duracao_minutos = @horario.agenda.duracao_slot_min || 30
    @preco_consulta = 150.00 # Valor padrão - pode ser configurado por especialidade/médico posteriormente
  end

  def create
    # LOG TEMPORÁRIO PARA DEBUG
    Rails.logger.info "🚀 MÉTODO CREATE CHAMADO! Params: #{params.inspect}"
    
    begin
      # Debug: logar informações do usuário atual
      Rails.logger.info "=== DEBUG AGENDAMENTO ==="
      Rails.logger.info "Current user: #{current_usuario.inspect}"
      Rails.logger.info "Current user paciente: #{current_usuario.paciente.inspect}"
      Rails.logger.info "Params: #{params.inspect}"

      # Buscar dados recebidos do formulário
      especialidade = Especialidade.find(params[:especialidade_id])
      medico = Medico.find(params[:medico_id])
      horario = Horario.find(params[:horario_id])

      # Verificar se o horário ainda está disponível
      unless horario.status == 'disponivel'
        redirect_to agendamento_path, alert: 'Horário não está mais disponível.'
        return
      end

      # Verificar se o paciente existe - com melhor debugging
      paciente = current_usuario.paciente
      unless paciente
        Rails.logger.error "ERRO: Usuário #{current_usuario.username} (ID: #{current_usuario.id}) não tem paciente associado"
        redirect_to agendamento_path, alert: "Erro: Usuário #{current_usuario.username} não tem registro de paciente. Contate o suporte."
        return
      end

      # Verificar se unidade tem salas
      unidade = horario.agenda.unidade
      sala = unidade.salas.first
      unless sala
        Rails.logger.error "ERRO: Unidade #{unidade.nome} não tem salas disponíveis"
        redirect_to agendamento_path, alert: 'Unidade não tem salas disponíveis.'
        return
      end

      # Criar a consulta seguindo o padrão do sistema
      consulta = Consulta.new(
        paciente: paciente,
        medico: medico,
        especialidade: especialidade,
        unidade: unidade,
        sala: sala,
        inicio: horario.inicio,
        fim: horario.fim,
        tipo: 'presencial',
        status: 'marcada',
        origem: 'app',
        observacoes: "Agendamento online - #{Time.current.strftime('%d/%m/%Y %H:%M')}"
      )

      if consulta.save
        # Marcar horário como reservado (não ocupado!)
        horario.update!(status: 'reservado')

        # Criar auditoria
        Auditoria.create!(
          entidade: 'Consulta',
          id_registro: consulta.id,
          acao: 'agendamento_criado',
          realizado_por: current_usuario.id,
          realizado_em: Time.current,
          diffs: {
            especialidade: especialidade.nome,
            medico: medico.nome,
            paciente: paciente.nome,
            data: horario.inicio.strftime('%d/%m/%Y %H:%M')
          }
        )

        Rails.logger.info "SUCCESS: Consulta criada com ID #{consulta.id}"
        redirect_to consultas_path, notice: 'Consulta agendada com sucesso!'
      else
        Rails.logger.error "ERRO ao salvar consulta: #{consulta.errors.full_messages}"
        redirect_to agendamento_path, alert: "Erro ao agendar consulta: #{consulta.errors.full_messages.join(', ')}"
      end

    rescue => e
      Rails.logger.error "EXCEÇÃO no agendamento: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to agendamento_path, alert: 'Erro interno no agendamento. Tente novamente.'
    end
  end

  private

  def require_patient_role
    unless current_usuario.papel == 'paciente'
      redirect_to root_path, alert: 'Apenas pacientes podem acessar o agendamento.'
    end
  end

  def buscar_horarios_disponiveis(agenda, data)
    # Verificar se é um dia da semana que o médico atende
    dias_semana_map = {
      0 => 'SUN', 1 => 'MON', 2 => 'TUE', 3 => 'WED',
      4 => 'THU', 5 => 'FRI', 6 => 'SAT'
    }
    dia_semana = dias_semana_map[data.wday]
    
    # CORREÇÃO: Tratar dias_semana como string CSV em vez de array
    dias_semana_array = agenda.dias_semana.to_s.split(',').map(&:strip)
    return [] unless dias_semana_array.include?(dia_semana)

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

    # CORREÇÃO: Usar as horas como strings e construir DateTime corretamente
    horario_atual = Time.zone.parse("#{data} #{hora_inicio}")
    horario_fim = Time.zone.parse("#{data} #{hora_fim}")

    while horario_atual < horario_fim
      # Verificar se já existe consulta neste horário
      consulta_existente = Consulta.where(
        medico: agenda.medico,
        inicio: horario_atual,
        status: ['marcada', 'confirmada', 'em_atendimento']
      ).exists?

      # Verificar se já existe horário criado
      horario_existente = agenda.horarios.where(inicio: horario_atual).exists?

      unless consulta_existente || horario_existente
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