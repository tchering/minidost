# frozen_string_literal: true

class Company < ApplicationRecord
  belongs_to :user
  has_many :addresses, dependent: :destroy
  after_initialize :build_default_addresses, if: :new_record?
  has_one_attached :logo

  validates :logo, content_type: ["image/png", "image/jpg", "image/jpeg"], size: { less_than: 4.megabytes, message: "is too big" }

  accepts_nested_attributes_for :addresses, allow_destroy: true

  validates :legal_status, presence: true
  validates :company_name, presence: true
  validates :siret_number, presence: true, uniqueness: true, format: { with: /\A[0-9A-Za-z]+\z/ }
  validates :activity_sector, presence: true
  validates :establishment_date, presence: true
  validates :employees_number, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :turnover, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  def thumbnail_logo
    logo.attached? ?
      logo.variant(:thumb).processed :
      DEFAULT_LOGO
  end

  private

  def build_default_addresses
    addresses.build if addresses.empty?
  end
end
