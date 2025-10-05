class CreatePacientePlanos < ActiveRecord::Migration[8.0]
  def change
    create_table :paciente_planos do |t|
      t.references :paciente, null: false, foreign_key: true
      t.references :plano, null: false, foreign_key: true
      t.string :numero_carteira
      t.date :validade

      t.timestamps
    end
  end
end
