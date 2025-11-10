class CreateHorarios < ActiveRecord::Migration[8.0]
  def change
    create_table :horarios do |t|
      t.references :agenda, null: false, foreign_key: true
      t.datetime :inicio
      t.datetime :fim
      t.string :status

      t.timestamps
    end
  end
end
