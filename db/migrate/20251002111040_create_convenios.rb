class CreateConvenios < ActiveRecord::Migration[8.0]
  def change
    create_table :convenios do |t|
      t.string :nome, limit: 100, null: false
      t.string :ans, limit: 20
      t.boolean :ativo, default: true

      t.timestamps
    end
  end
end
