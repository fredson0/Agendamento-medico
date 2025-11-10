class MedicoEspecialidade < ApplicationRecord
  belongs_to :medico
  belongs_to :especialidade
  
  # Validação de unicidade da combinação
  validates :medico_id, uniqueness: { scope: :especialidade_id }
end
