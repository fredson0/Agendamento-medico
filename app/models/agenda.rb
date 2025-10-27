class Agenda < ApplicationRecord
  belongs_to :medico
  belongs_to :unidade
  
  has_many :bloqueio_agendas, dependent: :destroy
  has_many :horarios, dependent: :destroy
  
  # Validações
  validates :duracao_slot_min, presence: true, numericality: { greater_than: 0 }
  validates :dias_semana, length: { maximum: 20 }, allow_blank: true
  validates :politica_intervalo, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validate :data_fim_depois_de_inicio
  validate :hora_fim_depois_de_inicio
  
  # Método para gerar horários da agenda
  def gerar_horarios
    return unless data_inicio && data_fim && hora_inicio && hora_fim
    
    (data_inicio..data_fim).each do |data|
      dia_semana = data.strftime('%a').upcase
      next unless dias_semana&.include?(dia_semana)
      
      horario_atual = Time.zone.parse("#{data} #{hora_inicio}")
      horario_final = Time.zone.parse("#{data} #{hora_fim}")
      
      while horario_atual < horario_final
        fim_slot = horario_atual + duracao_slot_min.minutes
        break if fim_slot > horario_final
        
        horarios.create(
          inicio: horario_atual,
          fim: fim_slot,
          status: 'disponivel'
        )
        
        horario_atual = fim_slot + (politica_intervalo || 0).minutes
      end
    end
  end
  
  private
  
  def data_fim_depois_de_inicio
    return if data_fim.blank? || data_inicio.blank?
    
    if data_fim < data_inicio
      errors.add(:data_fim, "deve ser depois da data de início")
    end
  end
  
  def hora_fim_depois_de_inicio
    return if hora_fim.blank? || hora_inicio.blank?
    
    if hora_fim <= hora_inicio
      errors.add(:hora_fim, "deve ser depois da hora de início")
    end
  end
end
