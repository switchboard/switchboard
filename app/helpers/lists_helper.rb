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

  def count_sent_messages(list)
    sent_state = MessageState.find_by_name('sent')
    list.messages.in_state(sent_state.id).length.to_s
  end

end
