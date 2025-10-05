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
  validates :status, inclusion: { in: %w[marcada confirmada em_atendimento concluida cancelada no_show] }
  validates :origem, inclusion: { in: %w[app recepcao] }
  validate :fim_depois_de_inicio
  
  private
  
  def fim_depois_de_inicio
    return if fim.blank? || inicio.blank?
    
    if fim <= inicio
      errors.add(:fim, "deve ser depois do início")
    end
  end
end
