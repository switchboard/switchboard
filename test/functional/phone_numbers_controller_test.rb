require 'test_helper'

class PhoneNumbersControllerTest < ActionController::TestCase

  setup do
    login_as :admin
  end

  context 'phone_numbers#list' do
    context 'with no list context' do
      should "show list of all organization's phone numbers in all lists" do
        get :index
        assert_template 'index'
        assert_select "td a", text: contacts(:one).full_name
        assert_select "td a", text: contacts(:two).full_name

        assert_links_to edit_contact_path(contacts(:one))
      end

      should "not include numbers in lists belonging to other organizations" do
        get :index

        assert_select "td a", text: contacts(:three).full_name, count: 0
      end

    end
    context 'with a list' do
      setup do
        @list = lists(:one)
      end
      should "show list of phone numbers, only those belonging to list" do
        get :index, list_id: @list.id
        assert_template 'index'
        assert_select "td a", text: contacts(:one).full_name
        assert_select "td a", text: contacts(:three).full_name, count: 0

        assert_links_to edit_list_contact_path(@list, contacts(:one))
      end

      context 'with xhr search' do
        should 'not render layout' do
          assert_template layout: nil
          get :index, list_id: @list.id, format: :xhr
        end

        should 'search records by name' do
          get :index, list_id: @list.id, format: :xhr, q: contacts(:one).first_name
          assert_select "td a", text: contacts(:one).full_name
          assert_select "td a", text: contacts(:two).full_name, count: 0
        end

        should 'search records by number' do
          get :index, list_id: @list.id, format: :xhr, q: phone_numbers(:two).number
          assert_select "td a", text: contacts(:two).full_name
          assert_select "td a", text: contacts(:one).full_name, count: 0
        end
      end
    end
  end

end
