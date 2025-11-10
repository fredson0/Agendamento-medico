class PacientePlano < ApplicationRecord
  belongs_to :paciente
  belongs_to :plano
  
  # Validações
  validates :numero_carteira, length: { maximum: 50 }, allow_blank: true
  validates :paciente_id, uniqueness: { scope: :plano_id }
  
  # Scopes
  scope :validos, -> { where('validade IS NULL OR validade >= ?', Date.today) }
  scope :vencidos, -> { where('validade < ?', Date.today) }
end
