ActionController::Routing::Routes.draw do |map|
 
  
  map.timeslice_smart_create 'timeslice-smart-create', :controller => 'timeslices', :action => 'smart_create'
  
  map.connect 'timesheet', :controller => 'timeslices', :action => 'timesheet'

  map.update_ar 'update-ar', :controller => 'timeslices', :action => 'update_ar'
  map.update_ar_save 'update-ar-save', :controller => 'timeslices', :action => 'update_ar_save', :method => :put

  map.connect 'sales-order-tracker', :controller => 'timeslices', :action => 'sales_order_tracker'
  map.sales_order_tracker '/sales-order-tracker/:ar', :controller => 'timeslices', :action => 'sales_order_tracker',
  :defaults => { :ar => nil }
  
  map.connect '/timesheet.:format', :controller => 'timeslices', :action => 'timesheet'
  map.timesheet '/timesheet/:date', :controller => 'timeslices', :action => 'timesheet',
  :requirements => { :date => /\d{4}-\d{2}-\d{2}/ }, :defaults => { :date => DateTime.now.strftime('%Y-%m-%d') }


  map.connect '/timesheet/:date.:format', :controller => 'timeslices', :action => 'timesheet'
  map.connect '/timeslices.ics', :controller => 'timeslices', :action => 'ical'
  
  map.resources :customers, :member => { :delete => :get } do |customer|
      customer.resources :projects, :member => { :delete => :get, :update_task_order => :put, :update_project_order => :put, :watch => :get, :enable_mail => :put, :disable_mail => :put }, :shallow => true do |project|
        project.resources :tasks, :member => { :delete => :get, :enable_mail => :put, :disable_mail => :put }, :shallow => true do |task|
          task.resources :comments, :shallow => true, :member => { :delete => :get }
          task.resources :timeslices, :shallow => true, :member => { :delete => :get }
        end
        project.resources :stakeholders, :shallow => true, :member => { :delete => :get }
      end
  end

  map.resources :users, :member => { :delete => :get }
  map.resources :password_resets
  map.resources :attachments, :member => { :delete => :get, :download => :get }

  map.connect 'project-order', :controller => 'projects', :action => 'update_project_order', :conditions => { :method => :put }
  map.project_order 'project-order', :controller => 'projects', :action => 'project_order'
  
  map.projects 'projects', :controller => 'projects', :action => 'index'
  map.project_deadlines 'deadlines.ics', :controller => 'projects', :action => 'ical'
  map.tasks 'tasks', :controller => 'tasks', :action => 'index'
  
  map.reports 'reports/:action', :controller => 'reports'

  map.reset 'reset', :controller => 'password_resets', :action => 'new'
  map.reset_password 'reset/:id', :controller => 'password_resets', :action => 'edit'
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.profile 'profile', :controller => 'users', :action => 'edit'
  map.register 'register', :controller => 'users', :action => 'new'
  map.resources :user_sessions

  map.connect '/dashboard/widget', :controller => 'dashboard', :action => 'widget'
  map.root :controller => "dashboard"
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action'
  map.connect ':controller/:action.:format'
  map.connect ':controller.:format'
  map.connect '*path', :controller => 'application', :action => 'show_404'
end
