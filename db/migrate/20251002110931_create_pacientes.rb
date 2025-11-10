class CreatePacientes < ActiveRecord::Migration[8.0]
  def change
    create_table :pacientes do |t|
      t.string :nome, limit: 150, null: false
      t.string :cpf, limit: 11, null: false
      t.date :data_nascimento
      t.string :telefone, limit: 20
      t.string :email, limit: 100
      t.string :sexo, limit: 1
      t.string :endereco, limit: 255
      t.references :usuario, null: true, foreign_key: true
      t.boolean :ativo, default: true

      t.timestamps
    end
    
    add_index :pacientes, :cpf, unique: true
  end
end
