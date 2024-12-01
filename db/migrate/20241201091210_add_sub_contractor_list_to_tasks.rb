class AddSubContractorListToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :sub_contractor_list, :integer, array: true, default: []
  end
end
