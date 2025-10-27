class Usuario < ApplicationRecord
  # usa password_digest com has_secure_password
  has_secure_password validations: false

  has_one :paciente, dependent: :destroy
  has_one :medico, dependent: :destroy
  has_many :auditorias, foreign_key: 'realizado_por', dependent: :nullify

  # Validações
  validates :username, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :papel, presence: true
  validates :papel, inclusion: { in: %w[paciente medico atendente admin] }
end

