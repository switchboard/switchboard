class AdminController < ApplicationController
  before_filter :require_user
  layout 'admin'
end
