class Task < ApplicationRecord
  belongs_to :taskable, polymorphic: true
  belongs_to :contractor, class_name: "User", foreign_key: "contractor_id"
  belongs_to :sub_contractor, class_name: "User", foreign_key: "sub_contractor_id"
end
