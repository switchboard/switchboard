ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all

  def login_as(user)
    @login_user = user ? users(user) : nil
    @request.cookies[:auth_token] = @login_user.try(:auth_token)
  end

  def assert_links_to(href, content=nil,message=nil)
    assert_tag tag: 'a', content: content, attributes: { href: href }
  end

  def assert_does_not_link_to(href, content=nil,message=nil)
    assert_no_tag tag: 'a', content: content, attributes: { href: href }
  end
end


VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
end