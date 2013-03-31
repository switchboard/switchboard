require 'test_helper'

class ContactsControllerTest < ActionController::TestCase

  setup do
    login_as :admin
  end

  context 'contacts#new' do
    should "render contact form" do
      get :new
      assert_template 'new'
      assert_select "input[name='contact[first_name]']"
    end
  end

  context 'contacts#create' do
    should 'show error when contact is invalid' do
      Contact.any_instance.stubs(:valid?).returns(false)
      post :create
      assert_select '.flash', /problem/
    end

    should 'add contact to list' do
      @list = lists(:one)
      List.any_instance.expects(:add_phone_number)
      @contact = FactoryGirl.build(:contact)
      post :create, list_id: @list.id, contact: @contact.attributes.slice(*Contact.accessible_attributes).merge({phone_numbers_attributes: {'0' => {'number' => '1231231234'}} })
    end

    should 'redirect when contact is saved' do
      Contact.any_instance.stubs(:save).returns(true)
      post :create
      assert_redirected_to lists_path
    end
  end

end
