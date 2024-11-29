# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :taskable, polymorphic: true
  belongs_to :contractor, class_name: 'User', foreign_key: 'contractor_id'
  belongs_to :sub_contractor, class_name: 'User', foreign_key: 'sub_contractor_id', optional: true

  validates :taskable_type, presence: { message: "Activity must be selected" }

  # This allows nested attributes for the associated taskable model
  accepts_nested_attributes_for :taskable, allow_destroy: true
end
