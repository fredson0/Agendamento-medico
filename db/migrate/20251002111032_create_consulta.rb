class CreateConsulta < ActiveRecord::Migration[8.0]
  def change
    create_table :consultas do |t|
      t.references :paciente, null: false, foreign_key: true
      t.references :medico, null: false, foreign_key: true
      t.references :unidade, null: false, foreign_key: true
      t.references :sala, null: true, foreign_key: true
      t.references :especialidade, null: true, foreign_key: true
      t.datetime :inicio, null: false
      t.datetime :fim, null: false
      t.string :tipo, default: 'presencial'
      t.string :status, default: 'marcada'
      t.string :origem, default: 'app'
      t.text :observacoes

      t.timestamps
    end
    
    add_index :consultas, :inicio
    add_index :consultas, :status
  end
end
