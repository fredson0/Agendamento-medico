class CreateSalas < ActiveRecord::Migration[8.0]
  def change
    create_table :salas do |t|
      t.references :unidade, null: false, foreign_key: true
      t.string :nome
      t.string :recursos
      t.boolean :ativa

      t.timestamps
    end
  end
end
