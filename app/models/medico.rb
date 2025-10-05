class Medico < ApplicationRecord
  belongs_to :usuario, optional: true
  
  has_many :medico_especialidades, dependent: :destroy
  has_many :especialidades, through: :medico_especialidades
  has_many :agendas, dependent: :destroy
  has_many :consultas, dependent: :restrict_with_error
  
  # Validações
  validates :nome, presence: true, length: { maximum: 150 }
  validates :crm, presence: true, length: { maximum: 20 }
  validates :uf_crm, presence: true, length: { is: 2 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :telefone, length: { maximum: 20 }, allow_blank: true
  
  # Scopes
  scope :ativos, -> { where(ativo: true) }
  scope :inativos, -> { where(ativo: false) }
end
