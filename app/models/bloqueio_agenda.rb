class BloqueioAgenda < ApplicationRecord
  belongs_to :agenda
  
  # Validações
  validates :inicio, :fim, presence: true
  validates :motivo, length: { maximum: 255 }, allow_blank: true
  validate :fim_depois_de_inicio
  
  # Callback para bloquear horários
  after_create :bloquear_horarios
  
  private
  
  def fim_depois_de_inicio
    return if fim.blank? || inicio.blank?
    
    if fim <= inicio
      errors.add(:fim, "deve ser depois do início")
    end
  end
  
  def bloquear_horarios
    agenda.horarios.where('inicio >= ? AND fim <= ?', inicio, fim)
         .update_all(status: 'bloqueado')
  end
end
