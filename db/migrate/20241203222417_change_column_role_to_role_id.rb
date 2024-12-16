class ChangeColumnRoleToRoleId < ActiveRecord::Migration[7.0]
  def change
    rename_column :members, :role, :role_id if column_exists? :members, :role
  end
end
