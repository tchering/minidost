# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :company
  validates :street, presence: true
  validates :area_code, presence: true
  validates :city, presence: true
  validates :country, presence: true
  before_create :set_default_country

  def full_address
    "#{street}, #{area_code} #{city}, #{country}"
  end

  private

  def set_default_country
    self.country ||= "France"
  end
end
