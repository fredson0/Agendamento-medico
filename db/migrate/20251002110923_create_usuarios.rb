class CreateUsuarios < ActiveRecord::Migration[8.0]
  def change
    create_table :usuarios do |t|
      t.string :username, limit: 50, null: false
      t.string :hash_senha, limit: 255, null: false
      t.string :papel, null: false
      t.boolean :mfa_enabled, default: false

      t.timestamps
    end
    
    add_index :usuarios, :username, unique: true
  end
end
