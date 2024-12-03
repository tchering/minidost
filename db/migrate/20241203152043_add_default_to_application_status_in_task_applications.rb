class AddDefaultToApplicationStatusInTaskApplications < ActiveRecord::Migration[7.1]
  def change
    change_column_default :task_applications, :application_status, from: nil, to: "pending"
  end
end
