# frozen_string_literal: true

class PeintreTask < ApplicationRecord
  has_one :task, as: :taskable, dependent: :destroy
end
