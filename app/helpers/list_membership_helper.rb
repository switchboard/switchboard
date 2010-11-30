module ListMembershipHelper

  def admin_checkbox_onchange(list_member)
    onchange = remote_function(
      :url => {:controller => 'lists', :action => 'toggle_admin'},
      :with => "'list_member_id=#{list_member.id}&list_id=#{@list.id}'" #,
      #:loading => show_spinner('which_list_spinner'),
      #:complete => hide_spinner('which_list_spinner'),
      #:after => "highlightList('list_id_#{list_id}')" # this is a javascript function
    ) 
  end

end
