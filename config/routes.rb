ActionController::Routing::Routes.draw do |map|

  map.timeslice_smart_create 'timeslice-smart-create', :controller => 'timeslices', :action => 'smart_create'

  map.connect 'timesheet', :controller => 'timeslices', :action => 'timesheet'

  map.update_ar 'update-ar', :controller => 'timeslices', :action => 'update_ar'
  map.update_ar_save 'update-ar-save', :controller => 'timeslices', :action => 'update_ar_save', :method => :put

  map.connect 'sales-order-tracker', :controller => 'timeslices', :action => 'sales_order_tracker'
  map.sales_order_tracker '/sales-order-tracker/:ar', :controller => 'timeslices', :action => 'sales_order_tracker',
  :defaults => { :ar => nil }

  map.connect 'invoice-tracker', :controller => 'timeslices', :action => 'invoice_tracker'
  map.invoice_tracker '/invoice-tracker/:invoice', :controller => 'timeslices', :action => 'invoice_tracker',
  :defaults => { :invoice => nil }

  map.connect '/timesheet.:format', :controller => 'timeslices', :action => 'timesheet'
  map.timesheet '/timesheet/:date', :controller => 'timeslices', :action => 'timesheet',
  :requirements => { :date => /\d{4}-\d{2}-\d{2}/ }, :defaults => { :date => DateTime.now.strftime('%Y-%m-%d') }

  map.connect '/timesheet/:date.:format', :controller => 'timeslices', :action => 'timesheet'
  map.connect '/timeslices.ics', :controller => 'timeslices', :action => 'ical'
  map.resources :timeslices, :except => [:index]

  map.resources :customers, :shallow => true, :member => { :delete => :get } do |customer|
    customer.resources :projects, :member => { :delete => :get, :update_task_order => :put, :update_project_order => :put, :watch => :get, :enable_mail => :put, :disable_mail => :put } do |project|
      project.resources :tasks, :member => { :delete => :get, :enable_mail => :put, :disable_mail => :put }, :collection => {:import => :get, :import_save => :post} do |task|
        task.resources :comments, :member => { :delete => :get }
        task.resources :timeslices, :member => { :delete => :get }
      end
      project.resources :stakeholders, :member => { :delete => :get }
    end
  end

  map.resources :users, :member => { :delete => :get }
  map.resources :password_resets
  map.resources :attachments, :member => { :delete => :get, :download => :get }

  map.resources :mailouts

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

  map.connect '/search', :controller => 'search', :action => 'search'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action'
  map.connect ':controller/:action.:format'
  map.connect ':controller.:format'
  map.connect '*path', :controller => 'application', :action => 'show_404'
end
