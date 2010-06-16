# Methods added to this helper will be available to all templates in the application.
module ListsHelper

  def display_welcome_message(list)
    list.use_welcome_message ? "display: inline" : "display: none"
  end

end
