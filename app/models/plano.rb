class Plano < ApplicationRecord
  belongs_to :convenio
  
  has_many :paciente_planos, dependent: :destroy
  has_many :pacientes, through: :paciente_planos
  
  # Validações
  validates :nome, presence: true, length: { maximum: 100 }
  
  # Serialização do JSON
  serialize :regras, coder: JSON
end
