require 'test_helper'

class GatewaysControllerTest < ActionController::TestCase
  setup do
    @gateway = gateways(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gateways)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gateway" do
    assert_difference('Gateway.count') do
      post :create, gateway: { cost_per_text: @gateway.cost_per_text, name: @gateway.name }
    end

    assert_redirected_to gateway_path(assigns(:gateway))
  end

  test "should show gateway" do
    get :show, id: @gateway
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gateway
    assert_response :success
  end

  test "should update gateway" do
    put :update, id: @gateway, gateway: { cost_per_text: @gateway.cost_per_text, name: @gateway.name }
    assert_redirected_to gateway_path(assigns(:gateway))
  end

  test "should destroy gateway" do
    assert_difference('Gateway.count', -1) do
      delete :destroy, id: @gateway
    end

    assert_redirected_to gateways_path
  end
end
