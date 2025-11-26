class Consulta < ApplicationRecord
  self.table_name = 'consultas'
  
  belongs_to :paciente
  belongs_to :medico
  belongs_to :unidade
  belongs_to :sala, optional: true
  belongs_to :especialidade, optional: true
  
  has_many :lembretes, dependent: :destroy
  has_many :pagamentos, dependent: :destroy
  
  # Validações
  validates :inicio, :fim, presence: true
  validates :tipo, :status, :origem, presence: true
  validates :tipo, inclusion: { in: %w[presencial teleconsulta] }
  validates :status, inclusion: { in: %w[marcada confirmada em_atendimento concluida cancelada no_show realizada] }
  validates :origem, inclusion: { in: %w[app recepcao] }
  validate :fim_depois_de_inicio
  
  # Scopes para diferentes tipos de consulta
  scope :realizadas, -> { where(status: 'realizada') }
  scope :historico_paciente, ->(paciente) { where(paciente: paciente, status: 'realizada').order(inicio: :desc) }
  scope :historico_medico, ->(medico) { where(medico: medico, status: 'realizada').order(inicio: :desc) }
  
  # Métodos para verificação de status
  def pode_ser_deletada?
    %w[marcada confirmada].include?(status) && inicio > Time.current
  end
  
  def foi_realizada?
    status == 'realizada'
  end
  
  def pode_adicionar_historico?
    %w[em_atendimento concluida realizada].include?(status)
  end

  def pode_ser_realizada?
    %w[confirmada em_atendimento].include?(status) && inicio <= Time.current
  end

  def tem_historico_completo?
    relatorio_medico.present? && data_realizacao.present?
  end

  # Gerar comprovante de atendimento automático
  def gerar_comprovante_atendimento
    return unless foi_realizada?
    
    comprovante = "COMPROVANTE DE ATENDIMENTO MÉDICO\n\n"
    comprovante += "Paciente: #{paciente.nome}\n"
    comprovante += "CPF: #{paciente.cpf}\n"
    comprovante += "Médico: #{medico.nome} - CRM: #{medico.crm}/#{medico.uf_crm}\n"
    comprovante += "Especialidade: #{especialidade&.nome || 'Clínica Geral'}\n"
    comprovante += "Data da Consulta: #{data_realizacao&.strftime('%d/%m/%Y às %H:%M') || inicio.strftime('%d/%m/%Y às %H:%M')}\n"
    comprovante += "Unidade: #{unidade.nome}\n"
    comprovante += "Tipo: #{tipo.titleize}\n\n"
    comprovante += "Este documento comprova que o paciente compareceu e foi atendido na data mencionada.\n\n"
    comprovante += "Gerado em: #{Time.current.strftime('%d/%m/%Y às %H:%M')}"
    
    update_column(:comprovante_atendimento, comprovante) if comprovante_atendimento.blank?
    comprovante
  end

  # Validação customizada para data de realização
  def data_realizacao_consistente
    return unless data_realizacao.present?
    
    if data_realizacao > Time.current
      errors.add(:data_realizacao, "não pode ser no futuro")
    end
    
    if data_realizacao < inicio
      errors.add(:data_realizacao, "não pode ser anterior ao horário agendado")
    end
  end
  
  private
  
  def fim_depois_de_inicio
    return if fim.blank? || inicio.blank?
    
    if fim <= inicio
      errors.add(:fim, "deve ser depois do início")
    end
  end
end
