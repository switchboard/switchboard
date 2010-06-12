module AdminHelper

  def select_list(action)
    render :partial => '/admin/list', :collection => List.find(:all), :locals => {:action => action}
    #collection_select(nil, nil, List.find(:all), :id, :name, {}, {:id => 'selectlist', :name => 'list_id', :multiple => 1, :size => 20, :onchange => onchange})  
  end

  def select_list_onclick(list_id, action)
    onclick = remote_function(
      :url => {:controller => 'admin', :action => action},
      :with => "'list_id=#{list_id}'",
      :loading => show_spinner('which_list_spinner'),
      :complete => hide_spinner('which_list_spinner'),
      :after => "highlightList('list_id_#{list_id}')" # this is a javascript function
    ) 
  end
 
  def link_to_remove_member(member)
    onclick = remote_function(
      :url => {:controller => 'admin', :action => 'remove_member'},
      :with => "'list_id='+$('selectlist').value+'&number_id=#{member.id}'",
      :loading => show_spinner('which_member_spinner'),
      :complete => hide_spinner('which_member_spinner')
    )
    link_to_remote_with_icon('remove.png', {:onclick => onclick})
  end

  def send_message_onclick(list_id)
    remote_function(
      :url => {:controller => 'admin', :action => 'send_message'},
      :with => "'list_id=#{list_id}&message_body='+$('message_body_textarea').value",
      :loading => show_spinner('send_message_spinner'),
      :complete => hide_spinner('send_message_spinner')
    )
  end

#  def select_list_members(memberships)
#    collection_select(nil, nil, memberships, :id, :display_for_select, {}, {:id => 'show_members', :multiple => 1, :size => 20) 
#  end

end
