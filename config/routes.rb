ActionController::Routing::Routes.draw do |map|

  map.connect 'timesheet', :controller => 'timeslices', :action => 'timesheet'

  map.update_ar 'update-ar', :controller => 'timeslices', :action => 'update_ar'
  map.update_ar_save 'update-ar-save', :controller => 'timeslices', :action => 'update_ar_save', :method => :put

  map.connect 'invoice-tracker', :controller => 'timeslices', :action => 'invoice_tracker'
  map.invoice_tracker '/invoice-tracker/:invoice', :controller => 'timeslices', :action => 'invoice_tracker',
  :defaults => { :invoice => nil }

  map.connect '/timesheet.:format', :controller => 'timeslices', :action => 'timesheet'
  map.timesheet '/timesheet/:date', :controller => 'timeslices', :action => 'timesheet',
  :requirements => { :date => /\d{4}-\d{2}-\d{2}/ }, :defaults => { :date => DateTime.now.strftime('%Y-%m-%d') }

  map.connect '/timesheet/:date.:format', :controller => 'timeslices', :action => 'timesheet'
  map.resources :timeslices, :except => [:index]

  map.resources :customers, :shallow => true, :member => { :delete => :get } do |customer|
    customer.resources :projects, :member => { :delete => :get } do |project|
      project.resources :tasks, :member => { :delete => :get }, :collection => {:import => :get, :import_save => :post} do |task|
        task.resources :timeslices, :member => { :delete => :get }
      end
    end
  end

  map.resources :users, :member => { :delete => :get }
  map.resources :password_resets
  map.resources :attachments, :member => { :delete => :get, :download => :get }

  map.resources :mailouts

  map.projects 'projects', :controller => 'projects', :action => 'index'

  map.reports 'reports/:action', :controller => 'reports'

  map.reset 'reset', :controller => 'password_resets', :action => 'new'
  map.reset_password 'reset/:id', :controller => 'password_resets', :action => 'edit'
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.profile 'profile', :controller => 'users', :action => 'edit'
  map.resources :user_sessions

  map.connect '/dashboard/widget', :controller => 'dashboard', :action => 'widget'
  map.root :controller => "dashboard"

  map.connect '/search.:format', :controller => 'search', :action => 'search'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action'
  map.connect ':controller/:action.:format'
  map.connect ':controller.:format'
  map.connect '*path', :controller => 'application', :action => 'show_404'
end
