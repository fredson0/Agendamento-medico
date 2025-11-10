class Horario < ApplicationRecord
  belongs_to :agenda
  
  # Validações
  validates :inicio, :fim, presence: true
  validates :status, presence: true
  validates :status, inclusion: { in: %w[disponivel reservado bloqueado] }
  validate :fim_depois_de_inicio
  
  # Scopes
  scope :disponiveis, -> { where(status: 'disponivel') }
  scope :reservados, -> { where(status: 'reservado') }
  scope :bloqueados, -> { where(status: 'bloqueado') }
  scope :por_data, ->(data) { where('DATE(inicio) = ?', data) }
  
  private
  
  def fim_depois_de_inicio
    return if fim.blank? || inicio.blank?
    
    if fim <= inicio
      errors.add(:fim, "deve ser depois do início")
    end
  end
end
