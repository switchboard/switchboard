module ApplicationHelper

  def active_nav(link)
    return "active" if link.match(/^#{Regexp.escape(request.path)}$/i)
  end

  def page_title(str)
    @page_title = str
  end

  def menu_item(link_text, url, current_if = false)
    capture_haml do
      haml_tag(:li, :<, class: current_if ? 'current' : nil) do
        haml_concat link_to(link_text, url)
      end
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

  def format_phone(num)
    return num if num == 'Web'
    num = num.to_s.gsub(/^\+1/,'').gsub(/[^0-9]/, '')
    if num.length == 10
      num = "#{num[0..2]}.#{num[3..5]}.#{num[6..9]}"
    end
    num
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
