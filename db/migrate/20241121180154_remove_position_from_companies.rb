# frozen_string_literal: true

class RemovePositionFromCompanies < ActiveRecord::Migration[7.1]
  def change
    remove_column :companies, :position, :string
  end
end
