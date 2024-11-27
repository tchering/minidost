class MakeSubContractorNullableInTasks < ActiveRecord::Migration[7.1]
  def change
    change_column_null :tasks, :sub_contractor_id, true
  end
end
