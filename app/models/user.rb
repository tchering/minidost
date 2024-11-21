# frozen_string_literal: true

class User < ApplicationRecord
  include SelectOption
  after_initialize :build_default_company, if: :new_record?
  after_initialize :set_default_admin, if: :new_record?

  # before_create :build_default_company
  # before_create :set_default_admin
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :email, :password, presence: true
  validates :email, uniqueness: true
  validates :companies, presence: true

  has_many :companies, dependent: :destroy
  accepts_nested_attributes_for :companies, allow_destroy: true

  private

  def build_default_company
    companies.build if companies.empty?
  end

  def set_default_admin
    self.admin ||= false
  end
end
