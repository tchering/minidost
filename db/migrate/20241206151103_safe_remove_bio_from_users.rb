class SafeRemoveBioFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :bio, :text if column_exists?(:users, :bio)
  end
end
