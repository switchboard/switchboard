class IncomingPhoneNumber < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_one :list

  scope :unassigned, -> {joins('LEFT JOIN `lists` ON `lists`.`incoming_phone_number_id` = `incoming_phone_numbers`.`id`').where('lists.id is null')}

  after_save :set_list_id
  before_destroy :remove_from_twilio

  def self.fetch_from_twilio
    TwilioClient.incoming_phone_numbers.each do |twilio_number|
      number = find_or_initialize_by_sid(twilio_number.sid)
      number.phone_number = twilio_number.phone_number
      number.created_at = twilio_number.date_created
      number.save!
    end
  end

  attr_writer :list_id
  def list_id
    list.try(:id)
  end

  private

  def set_list_id
    if @list_id.present? && ! list
      List.find(@list_id).update_column(:incoming_phone_number_id, id)
    end
  end

  def remove_from_twilio
    TwilioClient.delete_incoming_phone_number(sid)
  end
end
