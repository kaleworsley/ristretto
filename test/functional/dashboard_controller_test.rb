require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  setup :activate_authlogic

  def test_should_redirect_index_if_logged_out
    get :index
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_get_index
    UserSession.create(users(:user1))
    get :index
    assert_response :success
    assert assigns(:projects)
    assert assigns(:timeslices)
  end
end
