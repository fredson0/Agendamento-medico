class CreateMedicoEspecialidades < ActiveRecord::Migration[8.0]
  def change
    create_table :medico_especialidades do |t|
      t.references :medico, null: false, foreign_key: true
      t.references :especialidade, null: false, foreign_key: true

      t.timestamps
    end
  end
end
