require 'test_helper'

class StakeholdersControllerTest < ActionController::TestCase

  setup :activate_authlogic

  def test_index_routes
    # /projects/:project_id/stakeholders
    assert_recognizes({:controller => 'stakeholders', :action => 'index', :project_id => projects(:project1).id.to_s}, "projects/#{projects(:project1).id}/stakeholders")
    assert_routing("/projects/#{projects(:project1).id}/stakeholders.xml", { :controller => 'stakeholders', :action => 'index', :project_id => projects(:project1).id.to_s, :format => 'xml' })
  end

  def test_show_route
    # /stakeholders/:id
    assert_recognizes({:controller => 'stakeholders', :action => 'show', :id => stakeholders(:stakeholder1).id.to_s}, "/stakeholders/#{stakeholders(:stakeholder1).id}")
    assert_routing("/stakeholders/#{stakeholders(:stakeholder1).id}.xml", { :controller => 'stakeholders', :action => 'show', :format => 'xml', :id => stakeholders(:stakeholder1).id.to_s })
  end

  def test_edit_route
    # /stakeholders/:id/edit
    assert_recognizes({:controller => 'stakeholders', :action => 'edit', :id => stakeholders(:stakeholder1).id.to_s}, "/stakeholders/#{stakeholders(:stakeholder1).id}/edit")
  end

  def test_delete_route
    # /stakeholders/:id/delete
    assert_recognizes({:controller => 'stakeholders', :action => 'delete', :id => stakeholders(:stakeholder1).id.to_s}, "/stakeholders/#{stakeholders(:stakeholder1).id}/delete")
  end


  # Navigation

  # Show stakeholders
  def test_should_show_create_stakeholder_link_on_show_if_staff
    UserSession.create(users(:user1))
    get :show, :id => stakeholders(:stakeholder1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'New stakeholder'
  end

  def test_should_not_show_create_stakeholder_link_on_show_if_not_staff
    UserSession.create(users(:user2))
    get :show, :id => stakeholders(:stakeholder2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'New stakeholder', :count => 0 }
  end

  def test_should_show_edit_stakeholder_link_on_show_if_staff
    UserSession.create(users(:user1))
    get :show, :id => stakeholders(:stakeholder1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Edit'
  end

  def test_should_not_show_edit_stakeholder_link_on_show_if_not_staff
    UserSession.create(users(:user2))
    get :show, :id => stakeholders(:stakeholder2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'Edit', :count => 0 }
  end

  # New stakeholders
  def test_should_show_stakeholders_link_on_new_if_staff
    UserSession.create(users(:user1))
    get :new, :project_id => projects(:project1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Stakeholders'
  end

  def test_should_not_show_stakeholders_link_on_new_if_not_staff
    UserSession.create(users(:user2))
    get :new, :project_id => projects(:project2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'Stakeholders', :count => 0 }
  end

  # Edit stakeholders
  def test_should_show_view_stakeholder_link_on_edit_if_staff
    UserSession.create(users(:user1))
    get :edit, :id => stakeholders(:stakeholder1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'View'
  end

  def test_should_not_show_view_stakeholder_link_on_edit_if_not_staff
    UserSession.create(users(:user2))
    get :edit, :id => stakeholders(:stakeholder3).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'View', :count => 0 }
  end

  # Delete stakeholders

  def test_should_show_edit_stakeholder_link_on_delete_if_staff
    UserSession.create(users(:user1))
    get :delete, :id => stakeholders(:stakeholder3).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Edit'
  end

  def test_should_not_show_edit_stakeholder_link_on_delete_if_not_staff
    UserSession.create(users(:user2))
    get :delete, :id => stakeholders(:stakeholder2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'Edit', :count => 0 }
  end


  def test_should_redirect_index_if_logged_out
    get :index
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_get_index
    UserSession.create(users(:user1))
    get :index, :project_id => projects(:project1).id
    assert_response :success
    assert_not_nil assigns(:stakeholders)
    assert_equal 1, assigns(:stakeholders).length
  end

  def test_should_redirect_show_if_logged_out
    get :show, :id => stakeholders(:stakeholder1).id
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_show_stakeholder
    UserSession.create(users(:user1))
    get :show, :id => stakeholders(:stakeholder1).id
    assert_response :success
    assert_not_nil assigns(:stakeholder)
    assert_equal assigns(:stakeholder).id, stakeholders(:stakeholder1).id
  end

  def test_redirect_new_if_logged_out
    get :new
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_get_new
    UserSession.create(users(:user1))
    get :new, :project_id => projects(:project1).id
    assert_response :success
  end

  def test_should_redirect_create_if_logged_out
    post :create, :stakeholder => { :user_id => users(:user1).id,
                                    :project_id => projects(:project1).id,
                                    :role => 'project_manager'}
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_create_stakeholder
    UserSession.create(users(:user1))
    assert_difference('Stakeholder.count') do
      post :create, :project_id => projects(:project1).id, :stakeholder => { :user_id => users(:user1).id,
                                      :role => 'project_manager'}
    end
  end

  def test_should_redirect_edit_if_logged_out
    get :edit, :id => stakeholders(:stakeholder1).id
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_get_edit
    UserSession.create(users(:user1))
    get :edit, :id => stakeholders(:stakeholder1).id
    assert_response :success
    assert_not_nil assigns(:stakeholder)
  end

  def test_should_redirect_update_if_logged_out
    put :update, :id => stakeholders(:stakeholder1).id,
                 :stakeholder => { :user_id => users(:user1).id,
                                   :project_id => projects(:project1).id,
                                   :role => 'project_manager'}
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_update_stakeholder
    UserSession.create(users(:user1))
    put :update, :id => stakeholders(:stakeholder1).id,
                 :stakeholder => { :user_id => users(:user1).id,
                                   :project_id => projects(:project1).id,
                                   :role => 'project_manager'}
    assert_redirected_to project_url(stakeholders(:stakeholder1).project)
  end

  def test_should_redirect_destroy_if_logged_out
    delete :destroy, :id => stakeholders(:stakeholder1).id
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_destroy_stakeholder
    UserSession.create(users(:user1))
    assert_difference('Stakeholder.count', -1) do
      delete :destroy, :id => stakeholders(:stakeholder1).id
    end
  end
end
