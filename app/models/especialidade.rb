class Especialidade < ApplicationRecord
  has_many :medico_especialidades, dependent: :destroy
  has_many :medicos, through: :medico_especialidades
  has_many :consultas, dependent: :restrict_with_error
  
  # Validações
  validates :nome, presence: true, length: { maximum: 100 }
  validates :descricao, length: { maximum: 255 }, allow_blank: true
end
