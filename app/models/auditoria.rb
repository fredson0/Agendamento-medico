class Auditoria < ApplicationRecord
  self.table_name = 'auditorias'
  
  belongs_to :usuario, foreign_key: 'realizado_por', optional: true
  
  # Validações
  validates :entidade, :acao, presence: true
  
  # Serialização do JSON
  serialize :diffs, coder: JSON
end
