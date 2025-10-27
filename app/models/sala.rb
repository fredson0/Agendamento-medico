class Sala < ApplicationRecord
  belongs_to :unidade
  
  has_many :consultas, dependent: :restrict_with_error
  
  # Validações
  validates :nome, presence: true, length: { maximum: 100 }
  validates :recursos, length: { maximum: 255 }, allow_blank: true
  
  # Scopes
  scope :ativas, -> { where(ativa: true) }
  scope :inativas, -> { where(ativa: false) }
end
