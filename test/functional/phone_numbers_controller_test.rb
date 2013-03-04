require 'test_helper'

class PhoneNumbersControllerTest < ActionController::TestCase

  setup do
    login_as :admin
  end

  context 'phone_numbers#list' do
    context 'with no list context' do
      should "show list of all phone numbers in all lists" do
        get :index
        assert_template 'index'
        assert_select "td a", text: users(:one).full_name 
        assert_select "td a", text: users(:three).full_name 

        assert_links_to edit_user_path(users(:one))
      end
      
    end
    context 'with a list' do
      setup do
        @list = lists(:one)
      end
      should "show list of phone numbers, only those belonging to list" do
        get :index, list_id: @list.id
        assert_template 'index'
        assert_select "td a", text: users(:one).full_name 
        assert_select "td a", text: users(:three).full_name, count: 0

        assert_links_to edit_user_path(users(:one))
      end      
    end
  end

end
