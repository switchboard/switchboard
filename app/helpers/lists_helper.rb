module ListsHelper

  def display_welcome_message(list)
    list.use_welcome_message ? "display: inline" : "display: none"
  end

  #def check_list_availability_onblur
  # remote_function(
  #    :url => {:controller => 'lists', :action => 'check_name_available'},
  #     :with => "'name='+this.value",
  #    :loading => show_spinner('list_name_spinner'),
  #    :complete => hide_spinner('list_name_spinner')
  #  )
  #end

  def incoming_phone_numbers_for_list(list)
    numbers = IncomingPhoneNumber.unassigned.order(:phone_number).compact.collect{|p| [format_phone(p.phone_number), p.id] }
    if list.incoming_phone_number
      numbers.unshift ["#{format_phone(list.incoming_phone_number.phone_number)} (current)", list.incoming_phone_number_id ]
    end
    numbers
  end

  def count_sent_messages(list)
    list.messages.sent.size
  end

end
