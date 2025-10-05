class AllowNullHashSenhaInUsuarios < ActiveRecord::Migration[8.0]
  def up
    change_column_null :usuarios, :hash_senha, true
  end

  def down
    change_column_null :usuarios, :hash_senha, false
  end
end
