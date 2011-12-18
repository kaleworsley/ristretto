require 'test_helper'

class TasksControllerTest < ActionController::TestCase

  setup :activate_authlogic

  # Routes

  def test_index_routes
    # /tasks
    assert_recognizes({:controller => 'tasks', :action => 'index'}, 'tasks')
    assert_routing('/tasks.xml', { :controller => 'tasks', :action => 'index', :format => 'xml' })
    # /projects/:project_id/tasks
    assert_recognizes({:controller => 'tasks', :action => 'index', :project_id => projects(:project1).id.to_s}, "projects/#{projects(:project1).id}/tasks")
    assert_routing("/projects/#{projects(:project1).id}/tasks.xml", { :controller => 'tasks', :action => 'index', :project_id => projects(:project1).id.to_s, :format => 'xml' })
  end

  def test_show_route
    # /tasks/:id
    assert_recognizes({:controller => 'tasks', :action => 'show', :id => tasks(:task1).id.to_s}, "/tasks/#{tasks(:task1).id}")
    assert_routing("/tasks/#{tasks(:task1).id}.xml", { :controller => 'tasks', :action => 'show', :format => 'xml', :id => tasks(:task1).id.to_s })
  end

  def test_edit_route
    # /tasks/:id/edit
    assert_recognizes({:controller => 'tasks', :action => 'edit', :id => tasks(:task1).id.to_s}, "/tasks/#{tasks(:task1).id}/edit")
  end

  def test_delete_route
    # /tasks/:id/delete
    assert_recognizes({:controller => 'tasks', :action => 'delete', :id => tasks(:task1).id.to_s}, "/tasks/#{tasks(:task1).id}/delete")
  end


  # Navigation

  # Show tasks

  def test_should_show_create_timeslice_link_on_show_if_staff
    UserSession.create(users(:user1))
    get :show, :id => tasks(:task1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'New timeslice'
  end

  def test_should_not_show_create_timeslice_link_on_show_if_not_staff
    UserSession.create(users(:user2))
    get :show, :id => tasks(:task2).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', { :text => 'New timeslice', :count => 0 }
  end

  def test_should_show_edit_task_link_on_show_if_staff
    UserSession.create(users(:user1))
    get :show, :id => tasks(:task1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Edit'
  end

  # New tasks
  def test_should_show_tasks_link_on_new_if_staff
    UserSession.create(users(:user1))
    get :new, :project_id => projects(:project1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Tasks'
  end

  # Edit tasks
  def test_should_show_view_task_link_on_edit_if_staff
    UserSession.create(users(:user1))
    get :edit, :id => tasks(:task1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'View'
  end

  # Delete tasks
  def test_should_show_edit_task_link_on_delete_if_staff
    UserSession.create(users(:user1))
    get :delete, :id => tasks(:task1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Edit'
  end

  def test_should_redirect_index_if_logged_out
    get :index
    assert_redirected_to login_path
  end

  def test_should_get_index
    UserSession.create(users(:user1))
    get :index, :project_id => projects(:project1).id
    assert_response :success
    assert_not_nil assigns(:tasks)
    assert_equal 1, assigns(:tasks).length
    assert_menu_active 'Tasks'
  end

  def test_should_redirect_show_if_logged_out
    get :show, :id => tasks(:task1).id
    assert_redirected_to login_path
  end

  def test_should_show_task
    UserSession.create(users(:user1))
    get :show, :id => tasks(:task1).id
    assert_response :success
    assert_not_nil assigns(:task)
    assert_equal assigns(:task).id, tasks(:task1).id
    assert_menu_active 'Tasks'
  end

  def test_redirect_new_if_logged_out
    get :new
    assert_redirected_to login_path
  end

  def test_should_get_new
    UserSession.create(users(:user1))
    get :new, :project_id => projects(:project1).id
    assert_response :success
    assert_menu_active 'Tasks'
  end

  def test_should_redirect_create_if_logged_out
    post :create, :task => {:name => 'Test task',
                                :user_id => users(:user1).id }
    assert_redirected_to login_path
  end

  def test_should_create_task
    UserSession.create(users(:user1))
    assert_difference('projects(:project1).tasks.count') do
      post :create, :project_id => projects(:project1).id, :task => {:name => 'Test task',
                              :user_id => users(:user1).id,
                              :assigned_to_id => users(:user1).id}
    end
  end

  def test_should_redirect_edit_if_logged_out
    get :edit, :id => tasks(:task1).id
    assert_redirected_to login_path
  end

  def test_should_get_edit
    UserSession.create(users(:user1))
    get :edit, :id => tasks(:task1).id
    assert_response :success
    assert_not_nil assigns(:task)
    assert_menu_active 'Tasks'
  end

  def test_should_redirect_update_if_logged_out
    put :update, :id => tasks(:task1).id, :task => { :name => 'Test task'}
    assert_redirected_to login_path
  end

  def test_should_update_task
    UserSession.create(users(:user1))
    put :update, :id => tasks(:task1).id, :task => {
                              :name => 'Test task',
                              :user_id => users(:user1).id,
                              :assigned_to_id => users(:user1).id,
                              :project_id => projects(:project1).id}
    assert_redirected_to task_url(tasks(:task1))
  end

  test "should assign to current user when starting as task" do
    user = Factory.create(:user)

    task = Factory.create(:unassigned_task)
    assert_nil task.assigned_to
    assert_not_equal 'started', task.state
    task.project.add_stakeholder user

    put :update, :id => task.to_param, :task => { :state => 'started' }
    assert_equal user, assigns(:task).assigned_to
  end

  def test_should_redirect_delete_if_logged_out
    get :delete, :id => tasks(:task1).id
    assert_redirected_to login_path
  end

  def test_should_get_delete
    UserSession.create(users(:user1))
    get :delete, :id => tasks(:task1).id
    assert_response :success
    assert_not_nil assigns(:task)
    assert_menu_active 'Tasks'
  end

  def test_should_redirect_destroy_if_logged_out
    delete :destroy, :id => tasks(:task1).id
    assert_redirected_to login_path
  end

  def test_should_destroy_task
    UserSession.create(users(:user1))
    assert_difference('Task.count', -1) do
      delete :destroy, :id => tasks(:task1).id
    end
  end

  # API tests
  def test_should_not_get_index_xml_if_no_auth
    get :index, :format => 'xml'
    assert_response :forbidden
    assert_equal 'application/xml; charset=utf-8', @response.headers['Content-Type']
  end

  def test_should_not_get_index_xml_with_http_auth_is_not_staff
    http_auth users(:user2).email, 'testpass2'
    get :index, :format => 'xml'
    assert_response :forbidden
    assert_equal 'application/xml; charset=utf-8', @response.headers['Content-Type']
  end

  def test_should_get_index_xml_with_http_auth
    http_auth users(:user1).email, 'testpass1'
    get :index, :format => 'xml'
    assert_response :success
    assert_not_nil assigns(:tasks)
    assert_equal 3, assigns(:tasks).length
    assert_equal 'application/xml; charset=utf-8', @response.headers['Content-Type']
  end

  test "should be able to disable mail for a task" do
    http_auth users(:user1).email, 'testpass1'
    assert User.find(users(:user1).id).receive_mail_from?(tasks(:task1))
    put :disable_mail, :id => tasks(:task1).id
    assert_not_nil assigns(:task)
    assert User.find(users(:user1).id).ignore_mail_from?(tasks(:task1))
    assert_redirected_to task_path(tasks(:task1))
  end

  test "should be able to ensable mail for a task" do
    assert User.find(users(:user1).id).ignore_mail_from(tasks(:task1))
    http_auth users(:user1).email, 'testpass1'
    assert User.find(users(:user1).id).ignore_mail_from?(tasks(:task1))
    put :enable_mail, :id => tasks(:task1).id
    assert_not_nil assigns(:task)
    assert User.find(users(:user1).id).receive_mail_from?(tasks(:task1))
    assert_redirected_to task_path(tasks(:task1))
  end


end
