module AdministrationHelper


  # types are
  # success, notice, warning, error
  def jsnotify(msg, type, sticky = 'true')
    js = <<HERE
$j().toastmessage('showToast', {
            text     : '#{msg}',
            sticky   : true,
            position : 'top-right',
            type     : '#{type}',
            closeText: '',
        });
HERE
    puts js
    return js
  end

  def select_list(list_id, action, controller)
    # XXX correct?
    render :partial => '/admin/list', :collection => List.order(:name), :locals => {:action => action, :controller => controller, :list_id => list_id}
    #collection_select(nil, nil, List.find(:all), :id, :name, {}, {:id => 'selectlist', :name => 'list_id', :multiple => 1, :size => 20, :onchange => onchange})  
  end

  def list_class(list_id)
    (params[:selected_list] == list_id.to_s) ? 'active_list' : ""
  end

  def select_list_onclick(list_id, action, controller)
    onclick = remote_function(
      :url => {:controller => controller, :action => action},
      :with => "'list_id=#{list_id}'",
      :loading => show_spinner('which_list_spinner'),
      :complete => hide_spinner('which_list_spinner'),
      :after => "highlightList('list_id_#{list_id}')" # this is a javascript function
    ) 
  end

  def link_to_remove_member(phone_number, list_id)
    link_to image_tag('icons/16/remove.png'), list_phone_number_path(list_id: list_id, id: phone_number.id), remote: true, method: :delete
  end

  def link_to_remove_survey(survey)
    onclick = remote_function(
      :url => {:controller => 'admin', :action => 'remove_list'},
      :with => "'survey_id=#{survey.id}'",
      :loading => show_spinner("which_member_spinner_#{survey.id}"),
      :complete => hide_spinner("which_member_spinner_#{survey.id}")
    )
    link_to_remote_with_icon('icons/16/remove.png', {:onclick => onclick})
  end

  def send_message_onclick(list_id, confirmed=nil)
    confirmed = confirmed  ? "+'&confirmed=1'" : ''
    remote_function(
      :url => {:controller => 'admin', :action => 'send_message'},
      :with => "'list_id=#{list_id}&message_body='+$('message_body_textarea').value#{confirmed}",
      :loading => show_spinner('send_message_spinner'),
      :complete => hide_spinner('send_message_spinner')
    )
  end

  def edit_list_form
    if params[:selected_list]
      @list = List.find(params[:selected_list])
      render :partial => 'lists/edit'
    end
  end

#  def select_list_members(memberships)
#    collection_select(nil, nil, memberships, :id, :display_for_select, {}, {:id => 'show_members', :multiple => 1, :size => 20) 
#  end

end
