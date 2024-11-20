class Company < ApplicationRecord
  belongs_to :user
  has_many :addresses, dependent: :destroy

  accepts_nested_attributes_for :addresses, allow_destroy: true

  validates :legal_status, presence: true
  validates :company_name, presence: true
  validates :siret_number, presence: true, uniqueness: true
  validates :position, presence: true
  validates :activity_sector, presence: true
  validates :employees_number, presence: true
  validates :establishment_date, presence: true
  validates :turnover, presence: true
end
