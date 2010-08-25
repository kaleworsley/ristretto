require 'test_helper'

class CommentsControllerTest < ActionController::TestCase

  setup :activate_authlogic

def test_index_routes
  # /tasks/:task_id/comments
  assert_recognizes({:controller => 'comments', :action => 'index', :task_id => tasks(:task1).id.to_s}, "tasks/#{tasks(:task1).id}/comments")
  assert_routing("/tasks/#{tasks(:task1).id}/comments.xml", { :controller => 'comments', :action => 'index', :task_id => tasks(:task1).id.to_s, :format => 'xml' })
  end

  def test_show_route
    # /comments/:id
    assert_recognizes({:controller => 'comments', :action => 'show', :id => comments(:comment1).id.to_s}, "/comments/#{comments(:comment1).id}")
    assert_routing("/comments/#{comments(:comment1).id}.xml", { :controller => 'comments', :action => 'show', :format => 'xml', :id => comments(:comment1).id.to_s })
  end

  def test_edit_route
    # /comments/:id/edit
    assert_recognizes({:controller => 'comments', :action => 'edit', :id => comments(:comment1).id.to_s}, "/comments/#{comments(:comment1).id}/edit")
  end

  def test_delete_route
    # /comments/:id/delete
    assert_recognizes({:controller => 'comments', :action => 'delete', :id => comments(:comment1).id.to_s}, "/comments/#{comments(:comment1).id}/delete")
  end


  # Navigation

  # Show comments
  def test_should_show_create_comment_link_on_show_if_staff
    UserSession.create(users(:user1))
    get :show, :id => comments(:comment1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'New comment'
  end

  def test_should_show_edit_comment_link_on_show_if_staff
    UserSession.create(users(:user1))
    get :show, :id => comments(:comment1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Edit'
  end

  # New comments
  def test_should_show_comments_link_on_new_if_staff
    UserSession.create(users(:user1))
    get :new, :task_id => tasks(:task1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Comments'
  end


  # Edit comments
  def test_should_show_view_comment_link_on_edit_if_staff
    UserSession.create(users(:user1))
    get :edit, :id => comments(:comment1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'View'
  end

  def test_should_not_show_view_comment_link_on_edit_if_not_staff
    UserSession.create(users(:user2))
    get :edit, :id => comments(:comment3).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'View', :count => 0 }
  end

  # Delete comments

  def test_should_show_edit_comment_link_on_delete_if_staff
    UserSession.create(users(:user1))
    get :delete, :id => comments(:comment3).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Edit'
  end

  def test_should_redirect_index_if_logged_out
    get :index
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_get_index
    UserSession.create(users(:user1))
    get :index, :task_id => tasks(:task1).id
    assert_response :success
    assert_not_nil assigns(:comments)
    assert_equal 1, assigns(:comments).length
  end

  def test_should_redirect_show_if_logged_out
    get :show, :id => comments(:comment1).id
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_show_comment
    UserSession.create(users(:user1))
    get :show, :id => comments(:comment1).id
    assert_response :success
    assert_not_nil assigns(:comment)
    assert_equal assigns(:comment).id, comments(:comment1).id
  end

  def test_redirect_new_if_logged_out
    get :new
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_get_new
    UserSession.create(users(:user1))
    get :new, :task_id => tasks(:task1).id
    assert_response :success
  end

  def test_should_redirect_create_if_logged_out
    post :create, :comment => {:name => 'Test comment',
                                :user_id => users(:user1).id }
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_create_comment
    UserSession.create(users(:user1))
    assert_difference('Comment.count') do
      post :create, :task_id => tasks(:task1).id, :comment => {:body => 'Test comment'}, :notify => {:notify => 1}
    end
  end

  def test_should_redirect_edit_if_logged_out
    get :edit, :id => comments(:comment1).id
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_get_edit
    UserSession.create(users(:user1))
    get :edit, :id => comments(:comment1).id
    assert_response :success
    assert_not_nil assigns(:comment)
  end

  def test_should_redirect_update_if_logged_out
    put :update, :id => comments(:comment1).id, :comment => { :name => 'Test comment'}
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_update_comment
    UserSession.create(users(:user1))
    put :update, :id => comments(:comment1).id, :comment => {
      :body => 'Test comment', :task_id => tasks(:task1).id}
    assert_redirected_to task_url(comments(:comment1).task)
  end

  def test_should_redirect_destroy_if_logged_out
    delete :destroy, :id => comments(:comment1).id
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_destroy_comment
    UserSession.create(users(:user1))
    assert_difference('Comment.count', -1) do
      delete :destroy, :id => comments(:comment1).id
    end
  end

  # API tests
  def test_should_not_get_index_xml_if_no_auth
    get :index, :task_id => tasks(:task1).id, :format => 'xml'
    assert_response :forbidden
    assert_equal 'application/xml; charset=utf-8', @response.headers['Content-Type']
  end

  def test_should_get_index_xml_with_http_auth
    http_auth users(:user1).email, 'testpass1'
    get :index, :task_id => tasks(:task1).id, :format => 'xml'
    assert_response :success
    assert_not_nil assigns(:comments)
    assert_equal 1, assigns(:comments).length
    assert_equal 'application/xml; charset=utf-8', @response.headers['Content-Type']
  end
end
