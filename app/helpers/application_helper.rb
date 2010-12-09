# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def active_nav(link)
    return "active" if link.match(/^#{Regexp.escape(request.path)}$/i)
  end

  def dashboard_link
    @list ? list_path(@list) : '/admin/manage'
  end

  def compose_message_link
    @list ? new_list_message_path(@list) : '/admin/compose'
  end

  def add_user_link
    @list ? new_list_user_path(@list) : new_user_path
  end

  def show_spinner(id)
    "$('%s').show();" % id
  end

  def hide_spinner(id)
    "$('%s').hide();" % id
  end

  def prettify_ajax_errors(objects=[])
    html = '<ul class="flash_notice">'
    objects.each do |obj|
      obj.errors.full_messages.each do |msg|
        html << '<li>'+msg+'</li>'
      end
    end
    html << '</ul>'
  end

  def flash_messages
    [:notice, :warning, :message].collect do |key|
      content_tag(:div, flash[key], :class => "flash_#{key}") unless flash[key].blank?
    end.join
  end

  def link_to_remote_with_icon(icon, html_options={})
    image_tag("icons/16/#{icon}", html_options)
  end

end
