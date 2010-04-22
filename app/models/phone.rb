class Phone < ActiveRecord::Base

  has_many :phone_messages

  validates_format_of :number, :with => /^\d{10}$/

  def send_message(to_number, body, options={})
    # make message in Outgoing box
    msgbox = PhoneMessageBox.find_or_create_by_name('Outgoing')
    message = self.phone_messages.create!(:phone_message_box_id => msgbox.id, :body => body, :to => to_number)
  end

  def receive_message(from, body)
    # put message in incoming box
    msgbox = PhoneMessageBox.find_or_create_by_name('Inbox')
    message = self.phone_messages.create!(:phone_message_box_id => msgbox.id, :body => body, :from => from)
  end

end
