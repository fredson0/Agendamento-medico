class Pagamento < ApplicationRecord
  belongs_to :consulta
  
  # Validações
  validates :valor, presence: true, numericality: { greater_than: 0 }
  validates :forma, :status, presence: true
  validates :forma, inclusion: { in: %w[pix cartao dinheiro] }
  validates :status, inclusion: { in: %w[pendente aprovado estornado] }
  
  # Scopes
  scope :pendentes, -> { where(status: 'pendente') }
  scope :aprovados, -> { where(status: 'aprovado') }
  scope :estornados, -> { where(status: 'estornado') }
end
