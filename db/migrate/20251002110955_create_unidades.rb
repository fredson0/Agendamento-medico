class CreateUnidades < ActiveRecord::Migration[8.0]
  def change
    create_table :unidades do |t|
      t.string :nome, limit: 150, null: false
      t.string :cnpj, limit: 14
      t.string :endereco, limit: 255
      t.string :telefone, limit: 20

      t.timestamps
    end
    
    add_index :unidades, :cnpj, unique: true
  end
end
