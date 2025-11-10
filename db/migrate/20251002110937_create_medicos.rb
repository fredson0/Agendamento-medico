class CreateMedicos < ActiveRecord::Migration[8.0]
  def change
    create_table :medicos do |t|
      t.string :nome, limit: 150, null: false
      t.string :crm, limit: 20, null: false
      t.string :uf_crm, limit: 2, null: false
      t.string :telefone, limit: 20
      t.string :email, limit: 100
      t.references :usuario, null: true, foreign_key: true
      t.boolean :ativo, default: true

      t.timestamps
    end
    
    add_index :medicos, [:crm, :uf_crm], unique: true
  end
end
