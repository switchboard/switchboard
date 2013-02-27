module ListMembershipHelper

  def admin_checkbox_onchange(list_member)
=begin
    onchange = remote_function(
      :url => {:controller => 'lists', :action => 'toggle_admin'},
      :with => "'list_member_id=#{list_member.id}&list_id=#{@list.id}'",
      :loading => show_spinner("toggle_admin_spinner_#{list_member.id}"),
      :complete => hide_spinner("toggle_admin_spinner_#{list_member.id}")
      #:after => "highlightList('list_id_#{list_id}')" # this is a javascript function
    ) 
  end
=end
      end
end
