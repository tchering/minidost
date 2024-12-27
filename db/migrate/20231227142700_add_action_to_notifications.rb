class AddActionToNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :notifications, :action, :string
  end
end
