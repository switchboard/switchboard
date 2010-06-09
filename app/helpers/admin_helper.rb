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

#  def select_list_members(memberships)
#    collection_select(nil, nil, memberships, :id, :display_for_select, {}, {:id => 'show_members', :multiple => 1, :size => 20) 
#  end

end
