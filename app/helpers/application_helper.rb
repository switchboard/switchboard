# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def active_nav(link)
    return "active" if link.match(/^#{Regexp.escape(request.path)}$/i)
  end

end
