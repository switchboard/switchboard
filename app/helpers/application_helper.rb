module ApplicationHelper

  def active_nav(link)
    return "active" if link.match(/^#{Regexp.escape(request.path)}$/i)
  end

  def page_title(str)
    @page_title = str
  end

  def menu_item(link_text, url, icon_class, current_if = false, cls = '')
    capture_haml do
      haml_tag(:li, :<, class: "#{cls}#{'current' if current_if}") do
        if icon_class.present?
          link_text = add_icon(link_text, icon_class)
        end
        haml_concat link_to(link_text, url)
      end
    end
  end

  ICON_MAPPINGS = {
    add: 'plus-square',
    message: 'envelope',
    user: 'user',
    settings: 'cogs',
    upload: 'upload'
  }.freeze

  def add_icon(str, icon)
    capture_haml do
      haml_tag(:i, class: "fa fa-#{ICON_MAPPINGS[icon]}")
      haml_concat " #{str}"
    end
  end

  def add_contact_link
    @list ? new_list_contact_path(@list) : new_contact_path
  end

  def show_spinner(id)
    "$('%s').show();" % id
  end

  def hide_spinner(id)
    "$('%s').hide();" % id
  end

  def link_message_from(message)
    if message.sender.try(:first_name)
      if @list && @list.has_number?(message.from_phone_number)
        link_to message.sender.full_name, edit_list_contact_path(@list, message.sender)
      else
        message.sender.full_name
      end
    else
      format_phone(message.from)
    end
  end

  def message_from(message)
    if message.sender.try(:first_name)
      message.sender.full_name
    else
      format_phone(message.from)
    end
  end

  def submit_button(label, btn_class = 'button submit', opts = {})
    opts.merge!({class: btn_class, type: 'submit', 'data-disable-with' => 'Wait...'})
    opts[:accesskey] ||= 's'
    capture_haml do
      haml_tag(:button, :<, opts) do
        haml_concat label
      end
    end
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

  def custom_form_for(object, *args, &block)
    options = args.extract_options!
    simple_form_for(object, *(args << options.merge(builder: BetterFormBuilder)), &block)
  end

end
