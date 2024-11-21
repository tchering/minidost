# frozen_string_literal: true

class Company < ApplicationRecord
  belongs_to :user
  has_many :addresses, dependent: :destroy
  after_initialize :build_default_addresses, if: :new_record?

  # before_create :build_default_addresses

  accepts_nested_attributes_for :addresses, allow_destroy: true

  validates :legal_status, presence: true
  validates :company_name, presence: true
  validates :siret_number, presence: true, uniqueness: true, format: { with: /\A[0-9A-Za-z]+\z/ }
  validates :activity_sector, presence: true
  validates :establishment_date, presence: true
  validates :employees_number, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :turnover, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  private

  def build_default_addresses
    addresses.build if addresses.empty?
  end
end
