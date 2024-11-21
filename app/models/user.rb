# frozen_string_literal: true

class User < ApplicationRecord
  include SelectOption
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :companies, class_name: 'Company', foreign_key: 'user_id', dependent: :destroy
  accepts_nested_attributes_for :companies, allow_destroy: true
end
