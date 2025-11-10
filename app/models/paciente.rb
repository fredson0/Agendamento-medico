class Paciente < ApplicationRecord
  belongs_to :usuario, optional: true
  
  has_many :consultas, dependent: :destroy
  has_many :paciente_planos, dependent: :destroy
  has_many :planos, through: :paciente_planos
  
  # Validações
  validates :nome, presence: true, length: { maximum: 150 }
  validates :cpf, presence: true, uniqueness: true, length: { is: 11 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :telefone, length: { maximum: 20 }, allow_blank: true
  validates :sexo, inclusion: { in: %w[M F O] }, allow_blank: true
  
  # Scopes
  scope :ativos, -> { where(ativo: true) }
  scope :inativos, -> { where(ativo: false) }
end
