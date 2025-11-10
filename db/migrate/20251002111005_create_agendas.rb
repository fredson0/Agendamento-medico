class CreateAgendas < ActiveRecord::Migration[8.0]
  def change
    create_table :agendas do |t|
      t.references :medico, null: false, foreign_key: true
      t.references :unidade, null: false, foreign_key: true
      t.integer :duracao_slot_min
      t.date :data_inicio
      t.date :data_fim
      t.string :dias_semana
      t.time :hora_inicio
      t.time :hora_fim
      t.integer :politica_intervalo
      t.boolean :permite_teleconsulta

      t.timestamps
    end
  end
end
