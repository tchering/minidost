# frozen_string_literal: true

class ChangeEstablishedDateToYear < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      ALTER TABLE companies
      ALTER COLUMN establishment_date TYPE integer
      USING EXTRACT(YEAR FROM establishment_date)::integer;
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE companies
      ALTER COLUMN establishment_date TYPE date
      USING to_date(establishment_date::text, 'YYYY');
    SQL
  end
end
