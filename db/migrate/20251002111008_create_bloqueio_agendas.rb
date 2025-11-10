class CreateBloqueioAgendas < ActiveRecord::Migration[8.0]
  def change
    create_table :bloqueio_agendas do |t|
      t.references :agenda, null: false, foreign_key: true
      t.datetime :inicio
      t.datetime :fim
      t.string :motivo

      t.timestamps
    end
  end
end
