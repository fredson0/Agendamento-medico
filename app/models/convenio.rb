class Convenio < ApplicationRecord
  has_many :planos, dependent: :destroy
  
  # Validações
  validates :nome, presence: true, length: { maximum: 100 }
  validates :ans, length: { maximum: 20 }, allow_blank: true
  
  # Scopes
  scope :ativos, -> { where(ativo: true) }
  scope :inativos, -> { where(ativo: false) }
end
