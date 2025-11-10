class AddPasswordDigestToUsuarios < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_column :usuarios, :password_digest, :string

    # Copiar os hashes já existentes (são bcrypt) para o novo campo
    say_with_time "Copiando hash_senha para password_digest" do
      execute <<-SQL.squish
        UPDATE usuarios
        SET password_digest = hash_senha
        WHERE hash_senha IS NOT NULL;
      SQL
    end
  end

  def down
    remove_column :usuarios, :password_digest
  end
end
