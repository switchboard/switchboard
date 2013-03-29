class CleanupListIncomingNumber < ActiveRecord::Migration
  # Preventing broken migrations
  class List < ActiveRecord::Base
  end

  def up
    List.find_each do |list|
      next unless list.incoming_number.present?

      number = list.incoming_number.try(:gsub, /[^0-9]/, '')
      if number[0] == '1' && number.length == 11
        number = number[1..10]
      end
      list.update_column(:incoming_number, number)
    end
  end

  def down
    # Data-migration, no reversal
  end
end
