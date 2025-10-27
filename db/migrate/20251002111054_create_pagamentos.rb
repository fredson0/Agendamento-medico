class CreatePagamentos < ActiveRecord::Migration[8.0]
  def change
    create_table :pagamentos do |t|
      t.references :consulta, null: false, foreign_key: { to_table: :consultas }
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.string :forma
      t.string :status, default: 'pendente'

      t.timestamps
    end
    
    add_index :pagamentos, :status
  end
end
