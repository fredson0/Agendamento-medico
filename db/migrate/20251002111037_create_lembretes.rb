class CreateLembretes < ActiveRecord::Migration[8.0]
  def change
    create_table :lembretes do |t|
      t.references :consulta, null: false, foreign_key: { to_table: :consultas }
      t.string :canal
      t.datetime :enviado_em
      t.string :status, default: 'pendente'

      t.timestamps
    end
    
    add_index :lembretes, :status
  end
end
