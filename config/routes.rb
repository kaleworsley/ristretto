ActionController::Routing::Routes.draw do |map|
  map.resources :tickets

  map.timesheet 'timesheet.:format', :controller => 'timeslices', :action => 'timesheet'

  map.timesheet_calendar '/timesheet/calendar', :controller => 'timeslices', :action => 'calendar'
  
  map.add_timeslice '/timeslices/add', :controller => 'timeslices', :action => 'add', :conditions => {:method => :get}
  map.add_save_timeslice '/timeslices/add', :controller => 'timeslices', :action => 'add_save', :conditions => {:method => :post}

  map.resources :timeslices, :except => [:index]

  map.projects 'projects', :controller => 'projects', :action => 'index'
  map.projects_current 'projects/current', :controller => 'projects', :action => 'index', :index_scope => :current
  map.projects_proposed 'projects/proposed', :controller => 'projects', :action => 'index', :index_scope => :proposed
  map.projects_complete 'projects/complete', :controller => 'projects', :action => 'index', :index_scope => :complete
  map.projects_postponed 'projects/postponed', :controller => 'projects', :action => 'index', :index_scope => :postponed
  map.projects_support 'projects/support', :controller => 'projects', :action => 'index', :index_scope => :support
  map.projects_development 'projects/development', :controller => 'projects', :action => 'index', :index_scope => :development

  
  map.resources :customers, :shallow => true, :member => { :delete => :get }, :collection => { :missing => :get } do |customer|
    customer.resources :projects, :member => { :delete => :get, :uninvoiced => :get, :invoice => :post, :time => :get } do |project|
      project.resources :attachments, :only => [:index], :as => :files
      project.resources :tasks, :member => { :delete => :get } do |task|
        task.resources :timeslices, :member => { :delete => :get }
      end
    end
  end
  
  map.connect '/customers/xero/:xero_contact_id', :controller => 'customers', :action => 'xero'

  map.resources :users, :member => { :delete => :get }
  map.resources :password_resets
  map.resources :attachments, :member => { :delete => :get, :download => :get }, :as => :files, :except => [:index, :edit, :update]

  map.reset 'reset', :controller => 'password_resets', :action => 'new'
  map.reset_password 'reset/:id', :controller => 'password_resets', :action => 'edit'
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.profile 'profile', :controller => 'users', :action => 'edit'

  map.resources :user_sessions

  map.resources :contacts

  map.search '/search.:format', :controller => 'search', :action => 'search'

  map.connect '/search/:q', :controller => 'search', :action => 'search'

  map.root :controller => "dashboard"

  map.connect '*path', :controller => 'application', :action => 'show_404'

end
