require 'test_helper'

class ServicePhoneNumbersControllerTest < ActionController::TestCase
  setup do
    @service_phone_number = service_phone_numbers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:service_phone_numbers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create service_phone_number" do
    assert_difference('ServicePhoneNumber.count') do
      post :create, service_phone_number: { phone_number: @service_phone_number.phone_number, service: @service_phone_number.service }
    end

    assert_redirected_to service_phone_number_path(assigns(:service_phone_number))
  end

  test "should show service_phone_number" do
    get :show, id: @service_phone_number
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @service_phone_number
    assert_response :success
  end

  test "should update service_phone_number" do
    put :update, id: @service_phone_number, service_phone_number: { phone_number: @service_phone_number.phone_number, service: @service_phone_number.service }
    assert_redirected_to service_phone_number_path(assigns(:service_phone_number))
  end

  test "should destroy service_phone_number" do
    assert_difference('ServicePhoneNumber.count', -1) do
      delete :destroy, id: @service_phone_number
    end

    assert_redirected_to service_phone_numbers_path
  end
end
