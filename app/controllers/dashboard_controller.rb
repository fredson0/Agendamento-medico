class DashboardController < ApplicationController
  before_action :authenticate_usuario!

  def index
    @hoje = Date.current
    @agora = DateTime.current
    
    # Dados base por papel do usuário
    case current_usuario.papel
    when 'medico'
      load_medico_dashboard
    when 'paciente'
      load_paciente_dashboard
    else
      load_admin_dashboard
    end
    
    # Dados compartilhados
    load_shared_data
  end

  private

  def load_medico_dashboard
    medico = current_usuario.medico
    consultas_base = Consulta.where(medico: medico)
    
    @consultas_hoje = consultas_base.where(inicio: @hoje.beginning_of_day..@hoje.end_of_day).order(:inicio)
    @consultas_proximas = consultas_base.where('inicio > ?', @agora).order(:inicio).limit(5)
    @consultas_pendentes = consultas_base.where(status: 'marcada').where('inicio > ?', @agora).count
    
    # Estatísticas do médico
    @stats = {
      consultas_hoje: @consultas_hoje.count,
      consultas_semana: consultas_base.where(inicio: @hoje.beginning_of_week..@hoje.end_of_week).count,
      consultas_mes: consultas_base.where(inicio: @hoje.beginning_of_month..@hoje.end_of_month).count,
      confirmadas_hoje: @consultas_hoje.where(status: 'confirmada').count
    }
    
    @medicos = [medico]
    @pacientes_recentes = consultas_base.joins(:paciente).where('consultas.inicio >= ?', 30.days.ago)
                                       .select('DISTINCT pacientes.*').limit(8)
  end

  def load_paciente_dashboard
    @paciente = current_usuario.paciente
    consultas_base = Consulta.where(paciente: @paciente)
    
    @consultas_proximas = consultas_base.where('inicio > ?', @agora).order(:inicio).limit(5)
    @proxima_consulta = @consultas_proximas.first
    
    # Histórico do paciente
    @stats = {
      consultas_realizadas: consultas_base.where(status: 'concluida').count,
      consultas_agendadas: consultas_base.where(status: ['marcada', 'confirmada']).count,
      ultima_consulta: consultas_base.where(status: 'concluida').order(inicio: :desc).first&.inicio&.to_date
    }
    
    @medicos = Medico.ativos.joins(:consultas).where(consultas: { paciente: @paciente }).distinct.limit(5)
  end

  def load_admin_dashboard
    consultas_base = Consulta.all
    
    @consultas_hoje = consultas_base.where(inicio: @hoje.beginning_of_day..@hoje.end_of_day).order(:inicio)
    @consultas_proximas = consultas_base.where('inicio > ?', @agora).order(:inicio).limit(8)
    
    # Estatísticas gerais
    @stats = {
      consultas_hoje: @consultas_hoje.count,
      consultas_semana: consultas_base.where(inicio: @hoje.beginning_of_week..@hoje.end_of_week).count,
      consultas_mes: consultas_base.where(inicio: @hoje.beginning_of_month..@hoje.end_of_month).count,
      pacientes_ativos: Paciente.where(ativo: true).count,
      medicos_ativos: Medico.where(ativo: true).count,
      pendentes_confirmacao: consultas_base.where(status: 'marcada').where('inicio > ?', @agora).count
    }
    
    # Status das consultas hoje
    @consultas_por_status = @consultas_hoje.group(:status).count
    
    @medicos = Medico.ativos.limit(6)
    @pacientes = Paciente.ativos.order(:nome).limit(8)
    
    # Alertas
    @alertas = []
    
    # Consultas em atraso (deveria ter começado mas ainda não foi marcada como em atendimento)
    consultas_atrasadas = consultas_base.where(status: ['marcada', 'confirmada'])
                                       .where('inicio < ?', @agora - 15.minutes)
                                       .count
    if consultas_atrasadas > 0
      @alertas << { tipo: 'warning', mensagem: "#{consultas_atrasadas} consulta(s) em atraso" }
    end
    
    # Consultas sem confirmação para amanhã
    amanha = @hoje + 1.day
    sem_confirmacao = consultas_base.where(status: 'marcada')
                                   .where(inicio: amanha.beginning_of_day..amanha.end_of_day)
                                   .count
    if sem_confirmacao > 0
      @alertas << { tipo: 'info', mensagem: "#{sem_confirmacao} consulta(s) não confirmada(s) para amanhã" }
    end
  end

  def load_shared_data
    # Dados compartilhados entre todos os usuários
    @total_consultas_sistema = Consulta.count
    @data_atual = l(@hoje, format: :long)
  end
end
