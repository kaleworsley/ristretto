require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase

  setup :activate_authlogic

  # Routes
  def test_index_routes
    UserSession.create(users(:user1))
    # /projects
    assert_routing('/projects.xml', { :controller => 'projects', :action => 'index', :format => 'xml' })
    assert_recognizes({:controller => 'projects', :action => 'index'}, 'projects')
    # /customers/:customer_id/projects
    assert_routing("/customers/#{customers(:customer1).id}/projects.xml", { :controller => 'projects', :action => 'index', :format => 'xml', :customer_id => customers(:customer1).id.to_s })
    assert_recognizes({:controller => 'projects', :action => 'index', :customer_id => customers(:customer1).id.to_s}, "customers/#{customers(:customer1).id}/projects")
  end

  def test_show_route
    # /projects/:id
    assert_routing("/projects/#{projects(:project1).id}.xml", { :controller => 'projects', :action => 'show', :id => projects(:project1).id.to_s, :format => 'xml' })
    assert_recognizes({:controller => 'projects', :action => 'show', :id => projects(:project1).id.to_s}, "/projects/#{projects(:project1).id}")
  end

  def test_edit_route
    # /projects/:id/edit
    assert_recognizes({:controller => 'projects', :action => 'edit', :id => projects(:project1).id.to_s}, "/projects/#{projects(:project1).id}/edit")
  end

  def test_delete_route
    # /projects/:id/delete
    assert_recognizes({:controller => 'projects', :action => 'delete', :id => projects(:project1).id.to_s}, "/projects/#{projects(:project1).id}/delete")
  end


  # Navigation

  # Show projects

  def test_should_show_create_task_link_on_show_if_staff
    UserSession.create(users(:user1))
    get :show, :id => projects(:project1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'New task'
  end

  def test_should_show_create_task_link_on_show_if_not_staff
    UserSession.create(users(:user2))
    get :show, :id => projects(:project2).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', :text => 'New task'
  end

  def test_should_show_create_stakeholder_link_on_show_if_staff
    UserSession.create(users(:user1))
    get :show, :id => projects(:project1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'New stakeholder'
  end

  def test_should_not_show_create_stakeholder_link_on_show_if_not_staff
    UserSession.create(users(:user2))
    get :show, :id => projects(:project2).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', { :text => 'New stakeholder', :count => 0 }
  end

  def test_should_show_edit_project_link_on_show_if_staff
    UserSession.create(users(:user1))
    get :show, :id => projects(:project1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Edit'
  end

  def test_should_not_show_edit_project_link_on_show_if_not_staff
    UserSession.create(users(:user2))
    get :show, :id => projects(:project2).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', { :text => 'Edit', :count => 0 }
  end

  # New projects
  def test_should_show_projects_link_on_new_if_staff
    UserSession.create(users(:user1))
    get :new, :customer_id => customers(:customer1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Projects'
  end

  def test_should_not_show_projects_link_on_new_if_not_staff
    UserSession.create(users(:user2))
    get :new, :customer_id => customers(:customer2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'Projects', :count => 0 }
  end

  # Edit projects
  def test_should_show_create_task_link_on_edit_if_staff
    UserSession.create(users(:user1))
    get :edit, :id => projects(:project1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'New task'
  end

  def test_should_not_show_create_task_link_on_edit_if_not_staff
    UserSession.create(users(:user2))
    get :edit, :id => projects(:project2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'New task', :count => 0 }
  end

  def test_should_show_view_project_link_on_edit_if_staff
    UserSession.create(users(:user1))
    get :edit, :id => projects(:project1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'View'
  end

  def test_should_not_show_view_project_link_on_edit_if_not_staff
    UserSession.create(users(:user2))
    get :edit, :id => projects(:project2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'View', :count => 0 }
  end

  # Delete projects
  def test_should_show_create_task_link_on_delete_if_staff
    UserSession.create(users(:user1))
    get :delete, :id => projects(:project1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'New task'
  end

  def test_should_not_show_create_task_link_on_delete_if_not_staff
    UserSession.create(users(:user2))
    get :delete, :id => projects(:project2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'New task', :count => 0 }
  end

  def test_should_show_edit_project_link_on_delete_if_staff
    UserSession.create(users(:user1))
    get :delete, :id => projects(:project1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Edit'
  end

  def test_should_not_show_edit_project_link_on_delete_if_not_staff
    UserSession.create(users(:user2))
    get :delete, :id => projects(:project2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'Edit', :count => 0 }
  end


  def test_should_redirect_index_if_logged_out
    get :index
    assert_redirected_to login_path
  end

  def test_should_get_index_if_staff
    UserSession.create(users(:user1))
    get :index
    assert_response :success
    assert assigns(:projects)
    assert_equal 1, assigns(:projects).count
  end

  def test_should_get_index_if_not_staff
    UserSession.create(users(:user3))
    get :index
    assert_response :success
    assert assigns(:projects)
    assert_equal 1, assigns(:projects).count
  end

  def test_should_get_customer_index
    UserSession.create(users(:user1))
    get :index, :customer_id => customers(:customer1).id
    assert_response :success
    assert_not_nil assigns(:projects)
    assert_equal 1, assigns(:projects).length
    assert_menu_active 'Projects'
  end

  def test_should_redirect_show_if_logged_out
    get :show, :id => projects(:project1).id
    assert_redirected_to login_path
  end

  def test_should_show_project_if_is_staff
    UserSession.create(users(:user1))
    get :show, :id => projects(:project1).id
    assert_response :success
    assert_not_nil assigns(:project)
    assert_equal assigns(:project).id, projects(:project1).id
    assert_menu_active 'Projects'
  end

  def test_should_show_manage_project_links_if_is_staff
    UserSession.create(users(:user1))
    get :show, :id => projects(:project1).id
    assert_response :success
    assert_select 'div#nav a', { :text => 'Edit', :count => 1 }
  end

  def test_should_not_show_manage_project_links_if_not_staff
    UserSession.create(users(:user2))
    get :show, :id => projects(:project2).id
    assert_response :success
    assert_select 'div#nav a', { :text => 'New project', :count => 0 }
    assert_select 'div#nav a', { :text => 'Edit', :count => 0 }
  end

  def test_should_show_project_if_not_staff_and_stakeholder
    UserSession.create(users(:user3))
    get :show, :id => projects(:project2).id
    assert_response :success
    assert_not_nil assigns(:project)
    assert_equal assigns(:project).id, projects(:project2).id
    assert_menu_active 'Projects'
  end

  def test_should_not_show_project_if_not_staff_and_not_stakeholder
    UserSession.create(users(:user3))
    get :show, :id => projects(:project3).id
    assert_response :forbidden
  end

  def test_redirect_new_if_logged_out
    get :new
    assert_redirected_to login_path
  end

  def test_should_get_new_if_is_staff
    UserSession.create(users(:user1))
    get :new, :customer_id => customers(:customer1).id
    assert_response :success
    assert_menu_active 'Projects'
  end

  def test_should_not_get_new_if_not_staff
    UserSession.create(users(:user2))
    get :new, :customer_id => customers(:customer1).id
    assert_response :forbidden
  end

  def test_should_redirect_create_if_logged_out
    post :create, :project => {:name => 'Test project',
                                :user_id => users(:user1).id }
    assert_redirected_to login_path
  end

  def test_should_create_project_if_is_staff
    UserSession.create(users(:user1))
    stakeholder_count = Stakeholder.count
    assert_difference('Project.count') do
      post :create, :customer_id => customers(:customer1).id, :project => {:name => 'Test project'}
    end
    # The logged in user should only be assigned as a stakeholder when
    # this is explicitly requested.
    assert_equal stakeholder_count, Stakeholder.count, "created stakeholder but shouldn't have"
    assert assigns(:project)
    assert_redirected_to project_url(assigns(:project))
  end

  def test_should_create_project_if_is_staff
    UserSession.create(users(:user1))
    assert_difference(['Project.count','Stakeholder.count']) do
      post :create, :customer_id => customers(:customer1).id,
        :is_member => true, :stakeholder_role => 'project_manager',
        :project => {:name => 'Test project'}
    end
    assert assigns(:project)
    assert_redirected_to project_url(assigns(:project))
  end


  def test_should_not_create_project_if_not_staff
    UserSession.create(users(:user2))
    assert_no_difference('Project.count') do
      post :create, :customer_id => customers(:customer1).id, :project => {:name => 'Test project'}
    end
  end

  def test_should_redirect_edit_if_logged_out
    get :edit, :id => projects(:project1).id
    assert_redirected_to login_path
  end

  def test_should_get_edit_if_is_staff
    UserSession.create(users(:user1))
    get :edit, :id => projects(:project1).id
    assert_response :success
    assert_not_nil assigns(:project)
    assert_menu_active 'Projects'
  end

  def test_should_not_get_edit_if_not_staff
    UserSession.create(users(:user2))
    get :edit, :id => projects(:project2).id
    assert_response :forbidden
  end

  def test_should_redirect_update_if_logged_out
    put :update, :id => projects(:project1).id, :project => { :name => 'Test project'}
    assert_redirected_to login_path
  end

  def test_should_update_project_if_staff
    UserSession.create(users(:user1))
    put :update, :id => projects(:project1).id, :project => { :name => 'Test project'}
    assert_redirected_to project_url(projects(:project1))
  end

  def test_should_not_update_project_if_not_staff
    UserSession.create(users(:user2))
    put :update, :id => projects(:project2).id, :project => { :name => 'Test project'}
    assert_response :forbidden
  end

  def test_should_redirect_delete_if_logged_out
    get :delete, :id => projects(:project1).id
    assert_redirected_to login_path
  end

  def test_should_get_delete_if_staff
    UserSession.create(users(:user1))
    get :delete, :id => projects(:project1).id
    assert_response :success
    assert_not_nil assigns(:project)
    assert_menu_active 'Projects'
  end

  def test_should_not_get_delete_if_not_staff
    UserSession.create(users(:user2))
    get :delete, :id => projects(:project2).id
    assert_response :forbidden
  end

  def test_should_redirect_destroy_if_logged_out
    delete :destroy, :id => projects(:project1).id
    assert_redirected_to login_path
  end

  def test_should_destroy_project_if_staff
    UserSession.create(users(:user1))
    assert_difference('Project.count', -1) do
      delete :destroy, :id => projects(:project1).id
    end
  end

  def test_should_not_destroy_project_if_not_staff
    UserSession.create(users(:user2))
    assert_no_difference('Project.count') do
      delete :destroy, :id => projects(:project1).id
    end
    assert_response :forbidden
  end


  # API tests
  def test_should_not_get_index_xml_if_no_auth
    get :index_all, :format => 'xml'
    assert_response :forbidden
    assert_equal 'application/xml; charset=utf-8', @response.headers['Content-Type']
  end

  def test_should_not_get_index_xml_with_http_auth_is_not_staff
    http_auth users(:user2).email, 'testpass2'
    get :index_all, :format => 'xml'
    assert_response :forbidden
    assert_equal 'application/xml; charset=utf-8', @response.headers['Content-Type']
  end

  def test_should_get_index_xml_with_http_auth
    http_auth users(:user1).email, 'testpass1'
    get :index, :format => 'xml'
    assert_response :success
    assert_not_nil assigns(:projects)
    assert_equal 1, assigns(:projects).length
    assert_equal 'application/xml; charset=utf-8', @response.headers['Content-Type']
  end

  def test_should_create_project_with_http_auth
    http_auth users(:user1).email, 'testpass1'
    post :create, :customer_id => customers(:customer1).id, :project => { :name => 'Test project', :user_id => users(:user1).id, :state => 'current', }
    get :index, :customer_id => customers(:customer1).id, :format => 'xml'
    assert_not_nil assigns(:projects)
    assert_equal 2, assigns(:projects).length
    assert_equal 'application/xml; charset=utf-8', @response.headers['Content-Type']
  end

  def test_should_not_create_project_with_http_auth_is_not_staff
    http_auth users(:user2).email, 'testpass2'
    post :create, :customer_id => customers(:customer1).id, :project => { :name => 'Test project', :user_id => users(:user1).id, :state => 'current' }
    assert_response :forbidden
    assert_equal 3, Customer.find(:all).size
  end

  def test_should_update_project_with_http_auth
    http_auth users(:user1).email, 'testpass1'
    put :update, :id => projects(:project1).id, :project => { :name => 'Test project updated' }
    assert_equal 'Test project updated', Project.find(projects(:project1).id).name
  end

  def test_should_not_update_project_with_http_auth_is_not_staff
    http_auth users(:user2).email, 'testpass2'
    put :update, :id => projects(:project1).id, :project => { :name => 'Test project updated' }
    assert_response :forbidden
    assert_equal 'Project1', Project.find(projects(:project1).id).name
  end

  def test_should_destroy_project_with_http_auth
    http_auth users(:user1).email, 'testpass1'
    delete :destroy, :id => projects(:project1).id
    get :index, :customer_id => customers(:customer1).id, :format => 'xml'
    assert_not_nil assigns(:projects)
    assert_equal 0, assigns(:projects).length
  end

  def test_should_not_destroy_project_with_http_auth_is_not_staff
    http_auth users(:user2).email, 'testpass2'
    delete :destroy, :id => projects(:project1).id
    assert_response :forbidden
    assert_equal 3, Project.find(:all).size
  end

  test "should be able to disable mail for a project" do
    http_auth users(:user1).email, 'testpass1'
    assert User.find(users(:user1).id).receive_mail_from?(projects(:project1))
    put :disable_mail, :id => projects(:project1).id
    assert_not_nil assigns(:project)
    assert User.find(users(:user1).id).ignore_mail_from?(projects(:project1))
    assert_redirected_to project_path(projects(:project1))
  end

  test "should be able to ensable mail for a project" do
    assert User.find(users(:user1).id).ignore_mail_from(projects(:project1))
    http_auth users(:user1).email, 'testpass1'
    assert User.find(users(:user1).id).ignore_mail_from?(projects(:project1))
    put :enable_mail, :id => projects(:project1).id
    assert_not_nil assigns(:project)
    assert User.find(users(:user1).id).receive_mail_from?(projects(:project1))
    assert_redirected_to project_path(projects(:project1))
  end

end
