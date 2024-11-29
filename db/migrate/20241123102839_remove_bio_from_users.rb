# frozen_string_literal: true

class RemoveBioFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :bio, :text
  end
end
