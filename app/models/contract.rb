class Contract < ApplicationRecord
  belongs_to :task
  belongs_to :contractor
  belongs_to :subcontractor
  has_one_attached :pdf_file
end
