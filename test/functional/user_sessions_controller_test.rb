require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def test_should_get_new
    get :new
    assert_response :success
    assert_not_nil assigns(:user_session), "assigns a new session"
    assert_menu_active 'Login'
  end

  def test_should_get_create
    post :create, :user_session => {
      :email => 'test1@example.com', :password => 'testpass1' }
    assert_equal 'Logged in.', flash[:notice]
    assert_redirected_to root_url
  end

  def test_should_deny_destroy_if_not_logged_in
    delete :destroy
    assert_equal 'You must be logged in to view this page', flash[:warning]
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end
end
