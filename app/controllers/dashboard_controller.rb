class DashboardController < ApplicationController
  def index
    dashboard = cookies[:dashboardView]

    unless current_user.is_staff?
      dashboard = 'not_staff_dashboard'
    end

    case dashboard
    when 'assigned_tasks'
      @tasks = Task.paginate(:per_page => 50, :page => params[:page], :conditions => {:tasks => {:state => Task.stategroups[:current], :assigned_to_id => current_user.id}, :projects => {:state => 'current'}}, :include => :project, :order => 'projects.weight ASC, tasks.weight ASC')

      @partial = 'assigned_tasks'
    when 'projects_overview'
      @partial = 'projects_overview'

    when 'support_overview'
      @partial = 'support_overview'

    when 'project_tasks'
      @projects = current_user.current_projects.current
      @partial = 'project_tasks'

    when 'not_staff_dashboard'
      @tasks = Task.find(:all, :conditions => {:tasks => {:state => 'delivered'}, :projects => {:state => 'current', :id => current_user.current_projects_ids}}, :include => :project, :order => 'projects.weight ASC, tasks.weight ASC').find_all {|task| task.project.stakeholders.find(:all, :conditions => {:role => 'customer_representative', :user_id => current_user.id})}
      @projects = current_user.current_projects.current.find(:all, :order => :weight)
      @partial = 'not_staff_dashboard'

      # default to 'project_activity'
    else
      @projects = current_user.current_projects.current.find(:all, :order => :weight)
      @activity_items = current_user.activity_items
      @activity_items = @activity_items.sort_by {|a| a[:date]}
      @activity_items.reverse!
      @activity_dates = @activity_items.collect {|a| a[:date].to_date}.uniq
      @partial = 'project_activity'
    end

    respond_to do |format|
      format.html
    end
  end

  def widget
    respond_to do |format|
      format.html { render :partial => 'widget' }
    end
  end
end
