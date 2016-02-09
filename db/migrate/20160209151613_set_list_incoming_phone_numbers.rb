class SetListIncomingPhoneNumbers < ActiveRecord::Migration
  # A data-only migration
  def up
    IncomingPhoneNumber.fetch_from_stripe
    List.all.each do |list|
      next unless list.incoming_number.present?
      number = IncomingPhoneNumber.find_by_phone_number("+1#{list.incoming_number}")
      list.update_column(:incoming_phone_number_id, number.id) if number
    end
  end

  def down
    # no-op
  end
end