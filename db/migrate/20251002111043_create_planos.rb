class CreatePlanos < ActiveRecord::Migration[8.0]
  def change
    create_table :planos do |t|
      t.references :convenio, null: false, foreign_key: true
      t.string :nome
      t.text :regras

      t.timestamps
    end
  end
end
