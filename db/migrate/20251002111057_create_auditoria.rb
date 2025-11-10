class CreateAuditoria < ActiveRecord::Migration[8.0]
  def change
    create_table :auditorias do |t|
      t.string :entidade, limit: 50
      t.integer :id_registro
      t.string :acao, limit: 50
      t.integer :realizado_por
      t.datetime :realizado_em
      t.text :diffs

      t.timestamps
    end
    
    add_index :auditorias, :realizado_por
    add_index :auditorias, :entidade
    add_foreign_key :auditorias, :usuarios, column: :realizado_por
  end
end
