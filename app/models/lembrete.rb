class Lembrete < ApplicationRecord
  belongs_to :consulta
  
  # Validações
  validates :canal, :status, presence: true
  validates :canal, inclusion: { in: %w[email sms whatsapp] }
  validates :status, inclusion: { in: %w[pendente enviado erro] }
  
  # Scopes
  scope :pendentes, -> { where(status: 'pendente') }
  scope :enviados, -> { where(status: 'enviado') }
end
