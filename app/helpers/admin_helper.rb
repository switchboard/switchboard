module AdminHelper

  def select_list
    onchange = remote_function(
      :url => {:controller => 'admin', :action => 'show_members'},
      :with => "'list_id='+value",
      :loading => show_spinner('which_list_spinner'),
      :complete => hide_spinner('which_list_spinner')
    )
    collection_select(nil, nil, List.find(:all), :id, :name, {}, {:id => 'selectlist', :name => 'list_id', :multiple => 1, :size => 20, :onchange => onchange})  
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


#  def select_list_members(memberships)
#    collection_select(nil, nil, memberships, :id, :display_for_select, {}, {:id => 'show_members', :multiple => 1, :size => 20) 
#  end

end
