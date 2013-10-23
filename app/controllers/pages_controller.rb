class PagesController < ApplicationController
  skip_before_filter :require_user
  layout 'pages'

  def show
    @body_class = 'public'
    redirect_to lists_path and return if params[:template] == 'home' && current_user
    render params[:template]
  end
end
