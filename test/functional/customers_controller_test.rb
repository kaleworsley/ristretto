require 'test_helper'

class CustomersControllerTest < ActionController::TestCase

  setup :activate_authlogic

  # Routes
  def test_index_routes
    # /customers
    assert_routing('/customers.xml', { :controller => 'customers', :action => 'index', :format => 'xml' })
    assert_recognizes({:controller => 'customers', :action => 'index'}, 'customers')
  end

  def test_show_route
    # /customers/:id
    assert_routing("/customers/#{customers(:customer1).id}.xml", { :controller => 'customers', :action => 'show', :format => 'xml', :id => customers(:customer1).id.to_s })
    assert_recognizes({:controller => 'customers', :action => 'show', :id => customers(:customer1).id.to_s}, "/customers/#{customers(:customer1).id}")
  end

  def test_edit_route
    # /customers/:id/edit
    assert_recognizes({:controller => 'customers', :action => 'edit', :id => customers(:customer1).id.to_s}, "/customers/#{customers(:customer1).id}/edit")
  end

  def test_delete_route
    # /customers/:id/delete
    assert_recognizes({:controller => 'customers', :action => 'delete', :id => customers(:customer1).id.to_s}, "/customers/#{customers(:customer1).id}/delete")
  end

  # Navigation

  # Show customers

  def test_should_show_create_project_link_on_show_if_staff
    UserSession.create(users(:user1))
    get :show, :id => customers(:customer1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'New project'
  end

  def test_should_not_show_create_project_link_on_show_if_not_staff
    UserSession.create(users(:user2))
    get :show, :id => customers(:customer2).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', { :text => 'New project', :count => 0 }
  end

  def test_should_show_edit_customer_link_on_show_if_staff
    UserSession.create(users(:user1))
    get :show, :id => customers(:customer1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Edit'
  end

  def test_should_not_show_edit_customer_link_on_show_if_not_staff
    UserSession.create(users(:user2))
    get :show, :id => customers(:customer2).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', { :text => 'Edit', :count => 0 }
  end

  # Index customers
  def test_should_show_create_customer_link_on_index_if_staff
    UserSession.create(users(:user1))
    get :index
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'New customer'
  end

  def test_should_not_show_create_customer_link_on_index_if_not_staff
    UserSession.create(users(:user2))
    get :index
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'New customer', :count => 0 }
  end

  # New customers
  def test_should_show_customers_link_on_new_if_staff
    UserSession.create(users(:user1))
    get :new
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Customers'
  end

  def test_should_not_show_customers_link_on_new_if_not_staff
    UserSession.create(users(:user2))
    get :new
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'Customers', :count => 0 }
  end

  # Edit customers
  def test_should_show_create_project_link_on_edit_if_staff
    UserSession.create(users(:user1))
    get :edit, :id => customers(:customer1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'New project'
  end

  def test_should_not_show_create_project_link_on_edit_if_not_staff
    UserSession.create(users(:user2))
    get :edit, :id => customers(:customer2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'New project', :count => 0 }
  end

  def test_should_show_view_customer_link_on_edit_if_staff
    UserSession.create(users(:user1))
    get :edit, :id => customers(:customer1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'View'
  end

  def test_should_not_show_view_customer_link_on_edit_if_not_staff
    UserSession.create(users(:user2))
    get :edit, :id => customers(:customer2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'View', :count => 0 }
  end

  # Delete customers
  def test_should_show_create_project_link_on_delete_if_staff
    UserSession.create(users(:user1))
    get :delete, :id => customers(:customer1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'New project'
  end

  def test_should_not_show_create_project_link_on_delete_if_not_staff
    UserSession.create(users(:user2))
    get :delete, :id => customers(:customer2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'New project', :count => 0 }
  end

  def test_should_show_edit_customer_link_on_delete_if_staff
    UserSession.create(users(:user1))
    get :delete, :id => customers(:customer1).id
    assert_response :success
    assert_select 'div#nav ul#context-links a', 'Edit'
  end

  def test_should_not_show_edit_customer_link_on_delete_if_not_staff
    UserSession.create(users(:user2))
    get :delete, :id => customers(:customer2).id
    assert_response :forbidden
    assert_select 'div#nav ul#context-links a', { :text => 'Edit', :count => 0 }
  end

  #

  def test_should_redirect_index_if_logged_out
    get :index
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_get_index_if_staff
    UserSession.create(users(:user1))
    get :index
    assert_response :success
    assert_not_nil assigns(:customers)
    assert_equal 3, assigns(:customers).length
    assert_menu_active 'Customers'
  end

  def test_should_get_index_if_not_staff
    UserSession.create(users(:user2))
    get :index
    assert_response :forbidden
  end

  def test_should_redirect_show_if_logged_out
    get :show, :id => customers(:customer1).id
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_show_customer_if_staff
    UserSession.create(users(:user1))
    get :show, :id => customers(:customer1).id
    assert_response :success
    assert_not_nil assigns(:customer)
    assert_equal assigns(:customer).id, customers(:customer1).id
  end

  # If the user is not staff, but is a stakeholder on a customer
  # project, they should be able to view the customer.
  def test_should_show_customer_if_not_staff_but_stakeholder
    UserSession.create(users(:user2))
    get :show, :id => customers(:customer2).id
    assert_response :success
    assert_not_nil assigns(:customer)
    assert_equal assigns(:customer).id, customers(:customer2).id
  end

  def test_redirect_new_if_logged_out
    get :new
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_get_new_if_staff
    UserSession.create(users(:user1))
    get :new
    assert_response :success
    assert_menu_active 'Customers'
  end

  def test_should_not_get_new_if_not_staff
    UserSession.create(users(:user2))
    get :new
    assert_response :forbidden
  end

  def test_should_redirect_create_if_logged_out
    post :create, :customer => {:name => 'Test customer',
                                :user_id => users(:user1).id }
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_create_customer_if_staff
    UserSession.create(users(:user1))
    assert_difference('Customer.count') do
      post :create, :customer => {:name => 'Test customer'}
    end
  end

  def test_should_not_create_customer_if_not_staff
    UserSession.create(users(:user2))
    assert_no_difference('Customer.count') do
      post :create, :customer => {:name => 'Test customer'}
    end
    assert_response :forbidden
  end

  def test_should_redirect_edit_if_logged_out
    get :edit, :id => customers(:customer1).id
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_get_edit_if_staff
    UserSession.create(users(:user1))
    get :edit, :id => customers(:customer1).id
    assert_response :success
    assert_not_nil assigns(:customer)
    assert_menu_active 'Customers'
  end

  def test_should_not_get_edit_if_not_staff
    UserSession.create(users(:user2))
    get :edit, :id => customers(:customer2).id
    assert_response :forbidden
  end

  def test_should_redirect_update_if_logged_out
    put :update, :id => customers(:customer1).id, :customer => { :name => 'Test customer'}
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_update_customer_if_staff
    UserSession.create(users(:user1))
    put :update, :id => customers(:customer1).id, :customer => { :name => 'Test customer'}
    assert_redirected_to customer_url(customers(:customer1))
  end

  def test_should_not_update_customer_if_not_staff
    UserSession.create(users(:user2))
    put :update, :id => customers(:customer2).id, :customer => { :name => 'Test customer'}
    assert_response :forbidden
  end

  def test_should_redirect_delete_if_logged_out
    get :delete, :id => customers(:customer1).id
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_get_delete_if_staff
    UserSession.create(users(:user1))
    get :delete, :id => customers(:customer1).id
    assert_response :success
    assert_not_nil assigns(:customer)
    assert_menu_active 'Customers'
  end

  def test_should_not_get_delete_if_not_staff
    UserSession.create(users(:user2))
    get :delete, :id => customers(:customer2).id
    assert_response :forbidden
  end

  def test_should_redirect_destroy_if_logged_out
    delete :destroy, :id => customers(:customer1).id
    assert_redirected_to login_path.to_s + "?redirect=" + @request.path.to_s
  end

  def test_should_destroy_customer_if_staff
    UserSession.create(users(:user1))
    assert_difference('Customer.count', -1) do
      delete :destroy, :id => customers(:customer1).id
    end
  end

  def test_should_not_destroy_customer_if_not_staff
    UserSession.create(users(:user2))
    assert_no_difference('Customer.count') do
      delete :destroy, :id => customers(:customer2).id
    end
    assert_response :forbidden
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
    assert_not_nil assigns(:customers)
    assert_equal 3, assigns(:customers).length
    assert_equal 'application/xml; charset=utf-8', @response.headers['Content-Type']
  end

  def test_should_create_customer_with_http_auth
    http_auth users(:user1).email, 'testpass1'
    post :create, :customer => { :name => 'Test customer', :user_id => users(:user1).id }
    get :index, :format => 'xml'
    assert_not_nil assigns(:customers)
    assert_equal 4, assigns(:customers).length
    assert_equal 'application/xml; charset=utf-8', @response.headers['Content-Type']
  end

  def test_should_not_create_customer_with_http_auth_is_not_staff
    http_auth users(:user2).email, 'testpass2'
    post :create, :customer => { :name => 'Test customer', :user_id => users(:user1).id }
    assert_response :forbidden
    assert_equal 3, Customer.find(:all).size
  end

  def test_should_update_customer_with_http_auth
    http_auth users(:user1).email, 'testpass1'
    put :update, :id => customers(:customer1).id, :customer => { :name => 'Test customer updated' }
    assert_equal 'Test customer updated', Customer.find(customers(:customer1).id).name
  end

  def test_should_not_update_customer_with_http_auth_is_not_staff
    http_auth users(:user2).email, 'testpass2'
    put :update, :id => customers(:customer1).id, :customer => { :name => 'Test customer updated' }
    assert_response :forbidden
    assert_equal 'Customer1', Customer.find(customers(:customer1).id).name
  end

  def test_should_destroy_customer_with_http_auth
    http_auth users(:user1).email, 'testpass1'
    delete :destroy, :id => customers(:customer1).id
    get :index, :format => 'xml'
    assert_not_nil assigns(:customers)
    assert_equal 2, assigns(:customers).length
  end

  def test_should_not_destroy_customer_with_http_auth_is_not_staff
    http_auth users(:user2).email, 'testpass2'
    delete :destroy, :id => customers(:customer1).id
    assert_response :forbidden
    assert_equal 3, Customer.find(:all).size
  end

end
