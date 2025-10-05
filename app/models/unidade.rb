class Unidade < ApplicationRecord
  has_many :salas, dependent: :destroy
  has_many :agendas, dependent: :destroy
  has_many :consultas, dependent: :restrict_with_error
  
  # Validações
  validates :nome, presence: true, length: { maximum: 150 }
  validates :cnpj, uniqueness: true, length: { is: 14 }, allow_blank: true
  validates :telefone, length: { maximum: 20 }, allow_blank: true
end
