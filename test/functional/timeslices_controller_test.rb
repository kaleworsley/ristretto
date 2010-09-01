require 'test_helper'

class TimeslicesControllerTest < ActionController::TestCase

  setup :activate_authlogic

  def test_index_routes
    # /timeslices
    assert_recognizes({:controller => 'timeslices', :action => 'index'}, 'timeslices')
    assert_recognizes({:controller => 'timeslices', :action => 'index', :format => 'xml'}, "/timeslices.xml")
    # /tasks/:task_id/timeslices
    assert_recognizes({:controller => 'timeslices', :action => 'index', :task_id => tasks(:task1).id.to_s}, "tasks/#{tasks(:task1).id}/timeslices")
    assert_routing("/tasks/#{tasks(:task1).id}/timeslices.xml", { :controller => 'timeslices', :action => 'index', :task_id => tasks(:task1).id.to_s, :format => 'xml' })
  end

  def test_timesheet_routes
    # /timesheet
    assert_recognizes({:controller => 'timeslices', :action => 'timesheet', :format => 'js'}, "/timesheet.js")
    assert_recognizes({:controller => 'timeslices', :action => 'timesheet', :format => 'xml'}, "/timesheet.xml")
    assert_recognizes({:controller => 'timeslices', :action => 'timesheet'}, "/timesheet")

    # /timesheet/:date
    assert_recognizes({:controller => 'timeslices', :action => 'timesheet', :date => '2010-03-29'}, "/timesheet/2010-03-29")
    assert_routing("/timesheet/2010-03-29.xml", { :controller => 'timeslices', :action => 'timesheet', :format => 'xml', :date => '2010-03-29'})

  end

  def test_show_route
    # /timeslices/:id
    assert_recognizes({:controller => 'timeslices', :action => 'show', :id => timeslices(:timeslice1).id.to_s}, "/timeslices/#{timeslices(:timeslice1).id}")
    assert_routing("/timeslices/#{timeslices(:timeslice1).id}.xml", { :controller => 'timeslices', :action => 'show', :format => 'xml', :id => timeslices(:timeslice1).id.to_s })
  end

  def test_edit_route
    # /timeslices/:id/edit
    assert_recognizes({:controller => 'timeslices', :action => 'edit', :id => timeslices(:timeslice1).id.to_s}, "/timeslices/#{timeslices(:timeslice1).id}/edit")
  end

  def test_delete_route
    # /timeslices/:id/delete
    assert_recognizes({:controller => 'timeslices', :action => 'delete', :id => timeslices(:timeslice1).id.to_s}, "/timeslices/#{timeslices(:timeslice1).id}/delete")
  end




  # Navigation

  # Show timeslices
  def test_should_show_create_timeslice_link_on_show_if_staff
    UserSession.create(users(:user1))
    get :show, :id => timeslices(:timeslice1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'New timeslice'
  end

  def test_should_not_show_create_timeslice_link_on_show_if_not_staff
    UserSession.create(users(:user2))
    get :show, :id => timeslices(:timeslice2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'New timeslice', :count => 0 }
  end

  def test_should_show_edit_timeslice_link_on_show_if_staff
    UserSession.create(users(:user1))
    get :show, :id => timeslices(:timeslice1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Edit'
  end

  def test_should_not_show_edit_timeslice_link_on_show_if_not_staff
    UserSession.create(users(:user2))
    get :show, :id => timeslices(:timeslice2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'Edit', :count => 0 }
  end

  # New timeslices
  def test_should_show_timeslices_link_on_new_if_staff
    UserSession.create(users(:user1))
    get :new, :task_id => tasks(:task1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Timeslices'
  end

  def test_should_not_show_timeslices_link_on_new_if_not_staff
    UserSession.create(users(:user2))
    get :new, :task_id => tasks(:task2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'Timeslices', :count => 0 }
  end

  # Edit timeslices
  def test_should_show_view_timeslice_link_on_edit_if_staff
    UserSession.create(users(:user1))
    get :edit, :id => timeslices(:timeslice1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'View'
  end

  def test_should_not_show_view_timeslice_link_on_edit_if_not_staff
    UserSession.create(users(:user2))
    get :edit, :id => timeslices(:timeslice3).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'View', :count => 0 }
  end

  # Delete timeslices

  def test_should_show_edit_timeslice_link_on_delete_if_staff
    UserSession.create(users(:user1))
    get :delete, :id => timeslices(:timeslice1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Edit'
  end

  def test_should_not_show_edit_timeslice_link_on_delete_if_not_staff
    UserSession.create(users(:user2))
    get :delete, :id => timeslices(:timeslice2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'Edit', :count => 0 }
  end


  def test_should_get_index
    UserSession.create(users(:user1))
    get :index, :task_id => tasks(:task1).id
    assert_response :success
    assert_not_nil assigns(:timeslices)
    assert_equal 3, assigns(:timeslices).length
  end

  def test_should_redirect_show_if_logged_out
    get :show, :id => timeslices(:timeslice1).id
    assert_redirected_to login_path
  end

  def test_should_show_timeslice
    UserSession.create(users(:user1))
    get :show, :id => timeslices(:timeslice1).id
    assert_response :success
    assert_not_nil assigns(:timeslice)
    assert_equal assigns(:timeslice).id, timeslices(:timeslice1).id
  end

  def test_redirect_new_if_logged_out
    get :new
    assert_redirected_to login_path
  end

  def test_should_get_new
    UserSession.create(users(:user1))
    get :new, :task_id => tasks(:task1).id
    assert_response :success
  end

  def test_should_redirect_create_if_logged_out
    post :create, :task_id => tasks(:task1).id, :timeslice => {
                                :description => 'Test timeslice',
                                :user_id => users(:user1).id,
                                :started => '2010-04-05 04:14:46',
                                :finished => '2010-04-05 05:14:46',
                                :chargeable => true,
                                :ar => nil,
                                :ap => nil
                                }
    assert_redirected_to login_path
  end

  def test_should_create_task
    UserSession.create(users(:user1))
    assert_difference('Timeslice.count') do
      post :create, :task_id => tasks(:task1).id, :timeslice => {
                                :description => 'Test timeslice',
                                :user_id => users(:user1).id,
                                :started => '2010-04-05 04:14:46',
                                :finished => '2010-04-05 05:14:46',
                                :chargeable => true,
                                :ar => nil,
                                :ap => nil
                                }
    end
  end


  def test_should_redirect_edit_if_logged_out
    get :edit, :id => timeslices(:timeslice1).id
    assert_redirected_to login_path
  end

  def test_should_get_edit
    UserSession.create(users(:user1))
    get :edit, :id => timeslices(:timeslice1).id
    assert_response :success
    assert_not_nil assigns(:timeslice)
  end

  def test_should_return_403_if_edit_other_users_timeslice_and_not_staff
    UserSession.create(users(:user2))
    get :edit, :id => timeslices(:timeslice1).id
    assert_response :forbidden
  end

  def test_should_return_403_if_update_other_users_timeslice_and_not_staff
    UserSession.create(users(:user2))
    put :update, :id => timeslices(:timeslice1).id, :timeslice => {
                                :description => 'Test timeslice',
                                :user_id => users(:user1).id,
                                :started => '2010-04-05 04:14:46',
                                :finished => '2010-04-05 05:14:46',
                                :chargeable => true,
                                :ar => nil,
                                :ap => nil,
                                :task_id => tasks(:task1).id
                                }
    assert_response :forbidden
  end

  def test_should_redirect_update_if_logged_out
    put :update, :id => timeslices(:timeslice1).id, :timeslice => {
                                :description => 'Test timeslice',
                                :user_id => users(:user1).id,
                                :started => '2010-04-05 04:14:46',
                                :finished => '2010-04-05 05:14:46',
                                :chargeable => true,
                                :ar => nil,
                                :ap => nil,
                                :task_id => tasks(:task1).id
                                }
    assert_redirected_to login_path
  end

  def test_should_update_timeslice
    UserSession.create(users(:user1))
    put :update, :id => timeslices(:timeslice1).id, :timeslice => {
                                :description => 'Test timeslice',
                                :user_id => users(:user1).id,
                                :started => '2010-04-05 04:14:46',
                                :finished => '2010-04-05 05:14:46',
                                :chargeable => true,
                                :ar => nil,
                                :ap => nil,
                                :task_id => tasks(:task1).id
                                }
    assert_redirected_to task_url(timeslices(:timeslice1).task)
  end

  def test_should_redirect_destroy_if_logged_out
    delete :destroy, :id => timeslices(:timeslice1).id
    assert_redirected_to login_path
  end

  def test_should_destroy_timeslice
    UserSession.create(users(:user1))
    assert_difference('Timeslice.count', -1) do
      delete :destroy, :id => timeslices(:timeslice1).id
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
    assert_not_nil assigns(:timeslices)
    assert_equal 3, assigns(:timeslices).length
    assert_equal 'application/xml; charset=utf-8', @response.headers['Content-Type']
  end
end
