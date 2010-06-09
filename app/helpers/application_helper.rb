# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def active_nav(link)
    return "active" if link.match(/^#{Regexp.escape(request.path)}$/i)
  end

  def show_spinner(id)
    "$('%s').show();" % id
  end

  def hide_spinner(id)
    "$('%s').hide();" % id
  end

end
