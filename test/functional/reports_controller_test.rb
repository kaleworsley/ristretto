require 'test_helper'

class ReportsControllerTest < ActionController::TestCase

  setup :activate_authlogic

  test "should get timestats" do
    UserSession.create(users(:user1))
    get :timestats
    assert_response :success
    assert_equal 1, assigns(:staff).length
  end
end
