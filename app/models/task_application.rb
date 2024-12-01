class TaskApplication < ApplicationRecord
  #Rails will search for a task_id column in the task_applications table
  belongs_to :task
  #This is trying to say that the subcontractor_id is a foreign key that references the id of the User model
  belongs_to :subcontractor, class_name: "User", foreign_key: "subcontractor_id"
end
