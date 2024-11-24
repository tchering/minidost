# frozen_string_literal: true

class User < ApplicationRecord
  include SelectOption
  before_create :set_default_country
  after_initialize :set_default_admin, if: :new_record?
  # Tells geocoder which method to use for address
  geocoded_by :full_address
  # Automatically geocode when address fields change
  after_validation :geocode, if: ->(obj) {
                               obj.street_changed? || obj.area_code_changed? || obj.city_changed? || obj.country_changed?
                             }

  # Combines address fields into full address string
  def full_address
    "#{street}, #{area_code} #{city}, #{country}"
  end

  # before_create :build_default_company
  # before_create :set_default_admin
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :email, :password, presence: true
  validates :email, uniqueness: true

  #company validation
  validates :legal_status, presence: true
  validates :company_name, presence: true
  validates :siret_number, presence: true, uniqueness: true, format: { with: /\A[0-9A-Za-z]+\z/ }
  validates :activity_sector, presence: true
  validates :establishment_date, presence: true
  validates :employees_number, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :turnover, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  #address validation
  #  belongs_to :company
  validates :street, presence: true
  validates :area_code, presence: true
  validates :city, presence: true
  validates :country, presence: true
  before_create :set_default_country

  def full_address
    "#{street}, #{area_code} #{city}, #{country}"
  end

  #logo validation
  has_one_attached :logo

  validates :logo, content_type: ["image/png", "image/jpg", "image/jpeg"], size: { less_than: 4.megabytes, message: "is too big" }

  # Position validations and helper methods
  validates :position, presence: true, inclusion: { in: ["Donneur-d'ordre", "Sous-traitant"] }

  #helper methods for position checks
  def contractor?
    position == "Donneur-d'ordre"
  end

  def subcontractor?
    position == "Sous-traitant"
  end

  def thumbnail_logo
    logo.attached? ?
      logo.variant(:thumb).processed :
      DEFAULT_LOGO
  end

  private

  def set_default_admin
    self.admin ||= false
  end

  def set_default_country
    self.country ||= "France"
  end
end
