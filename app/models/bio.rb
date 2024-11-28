class Bio < ApplicationRecord
  belongs_to :user

  validates :text, presence: true, length: { minimum: 10, maximum: 1000 }
end
