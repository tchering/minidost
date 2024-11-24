class ChangeEstablishmentDateToInteger < ActiveRecord::Migration[7.1]
  def change
    change_column :users, :establishment_date, :integer,
      using: 'EXTRACT(YEAR FROM establishment_date)::integer'
  end
end
