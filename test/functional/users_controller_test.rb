require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  setup :activate_authlogic

  def test_index_routes
    # /users
    assert_recognizes({:controller => 'users', :action => 'index'}, 'users')
    assert_routing('/users.xml', { :controller => 'users', :action => 'index', :format => 'xml' })
  end

  def test_show_route
    # /users/:id
    assert_recognizes({:controller => 'users', :action => 'show', :id => users(:user1).id.to_s}, "/users/#{users(:user1).id}")
    assert_routing("/users/#{users(:user1).id}.xml", { :controller => 'users', :action => 'show', :format => 'xml', :id => users(:user1).id.to_s })
  end

  def test_edit_route
    # /users/:id/edit
    assert_recognizes({:controller => 'users', :action => 'edit', :id => users(:user1).id.to_s}, "/users/#{users(:user1).id}/edit")
  end

  def test_delete_route
    # /users/:id/delete
    assert_recognizes({:controller => 'users', :action => 'delete', :id => users(:user1).id.to_s}, "/users/#{users(:user1).id}/delete")
  end

  def test_should_get_new
    get :new
    assert_not_nil assigns(:user)
    assert_response :success
    assert_menu_active 'Register'
  end

  def test_should_not_show_user_when_not_logged_in
    get :show, :id => users(:user1).id
    assert_redirected_to login_path
  end

  def test_should_show_own_user_when_logged_in
    UserSession.create(users(:user1))
    get :show, :id => users(:user1).id
    assert_response :success
    assert assigns(:user)
    assert_equal users(:user1), assigns(:user)
    assert_menu_active 'Edit Profile'
  end

  # TODO Permissions on this may need refining.  At the time of writing
  # any user can view any other user
  def test_should_show_another_user_when_logged_in_if_the_other_user_is_a_member_of_the_same_project
    UserSession.create(users(:user2))
    get :show, :id => users(:user3).id
    assert_response :success
    assert assigns(:user)
    assert_equal users(:user3), assigns(:user)
    assert_menu_active 'Edit Profile'
  end

  def test_should_create_user
    assert_difference('User.count') do
      post :create, :user => {
        :name => 'Test User', :email => 'test@example.com',
        :first_name => 'asdasd', :last_name => 'asdasd',
        :password => 'password', :password_confirmation => 'password'
      }
    end
  end

  def test_should_not_create_user_with_empty_passwords
    post :create, :user => {
      :name => 'Test User', :email => 'test@example.com',
      :first_name => 'asdasd', :last_name => 'asdasd'
    }
    assert_response :success
    assert assigns(:user)
    assert assigns(:user).errors.on(:password).include?("is too short")
    assert_menu_active 'Register'
  end

  def test_should_not_create_user_without_matching_password_confirmation
    post :create, :user => {
      :name => 'Test User', :email => 'test@example.com',
      :first_name => 'asdasd', :last_name => 'asdasd',
      :password => 'password', :password_confirmation => 'flumword'
    }
    assert_response :success
    assert assigns(:user)
    assert_equal "doesn't match confirmation", assigns(:user).errors.on(:password)
    assert_menu_active 'Register'
  end

  def test_should_not_edit_user_when_not_logged_in
    get :edit
    assert_redirected_to login_path
  end

  def test_should_not_create_user_when_logged_in
    UserSession.create(users(:user1))
    post :create, :user => {
      :name => 'Test User', :email => 'test@example.com',
      :first_name => 'asdasd', :last_name => 'asdasd',
      :password => 'password', :password_confirmation => 'password'
    }
    assert_redirected_to root_url
  end

  def test_should_edit_user
    UserSession.create(users(:user1))
    put :update, :id => users(:user1).id, :user => {
      :name => 'Test User', :email => 'test@example.com',
      :first_name => 'asdasd', :last_name => 'asdasd',
      :password => 'password', :password_confirmation => 'password'
    }
    assert_redirected_to user_path(users(:user1))
  end

  def test_should_edit_other_user_if_is_staff
    UserSession.create(users(:user1))
    put :update, :id => users(:user2).id, :user => {
      :name => 'Test User', :email => 'test@example.com',
      :first_name => 'asdasd', :last_name => 'asdasd',
      :password => 'password', :password_confirmation => 'password'
    }
    assert_redirected_to user_url(users(:user2))
  end

  # Only users with is_staff flag should be able to set is_staff
  # on another user.
  def test_should_promote_user_to_is_staff_if_is_staff
    UserSession.create(users(:user1))
    put :update, :id => users(:user2).id, :user => { :is_staff => true }
    assert assigns(:user)
    assert assigns(:user).is_staff
    assert_redirected_to user_url(users(:user2))
  end

  def test_should_not_promote_self_to_staff
    UserSession.create(users(:user2))
    put :update, :id => users(:user2).id, :user => { :is_staff => true }
    assert assigns(:user)
    assert !assigns(:user).is_staff
    assert_redirected_to user_url(users(:user2))
  end

  def test_should_not_edit_other_user_if_not_staff
    UserSession.create(users(:user2))
    put :update, :id => users(:user1).id, :user => {
      :name => 'Test User', :email => 'test@example.com',
      :first_name => 'asdasd', :last_name => 'asdasd',
      :password => 'password', :password_confirmation => 'password'
    }
    assert_response :forbidden
  end

  def test_should_edit_user_without_password
    UserSession.create(users(:user1))
    put :update, :id => users(:user1).id, :user => {
      :name => 'Test User', :email => 'test@example.com',
      :first_name => 'asdasd', :last_name => 'asdasd'
    }
    assert_redirected_to user_url(users(:user1))
  end

  # API tests
  def test_should_not_get_index_xml_if_no_auth
    get :index, :format => 'xml'
    assert_response :forbidden
    assert_equal 'application/xml; charset=utf-8', @response.headers['Content-Type']
  end

  def test_should_get_index_xml_with_http_auth_if_staff
    http_auth users(:user1).email, 'testpass1'
    get :index, :format => 'xml'
    assert_response :success
    assert_not_nil assigns(:users)
    assert_equal 3, assigns(:users).length
    assert_equal 'application/xml; charset=utf-8', @response.headers['Content-Type']
  end

end
