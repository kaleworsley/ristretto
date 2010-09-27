class ReportsController < ApplicationController
  def timestats
    @staff = User.staff
    respond_to do |format|
      format.html
    end
  end

  def timestats_summary
    begin
      @start_date = Time.at(params[:start_date].to_i).to_date
      @end_date = Time.at(params[:end_date].to_i).to_date
    rescue
      @start_date = Date.today.beginning_of_week
      @end_date = Date.today.end_of_week
    end

    @timeslices = Timeslice.by_date(@start_date, @end_date)

    respond_to do |format|
      format.html
    end
  end

  def timesheets

    begin
      @start_date = Date.parse(params[:start_date])
      @end_date = Date.parse(params[:end_date])
    rescue
      @start_date = Date.today.beginning_of_week
      @end_date = Date.today.end_of_week
    end

    if params[:user].present?
      @user = User.find(params[:user])
      @timeslices = @user.timeslices.by_date(@start_date.to_time, @end_date.to_time)

      respond_to do |format|
        format.html
      end
    end

  end

  def monthly_report
    begin
      @project = current_user.current_projects.find(params[:project][:id])
    rescue
    end

    begin
      @date = Date.new(DateTime.now.year.to_i, params[:date][:month].to_i, 1)
    rescue
      @date = DateTime.now.to_date
    end

    unless @project.nil?
      @timeslices = Timeslice.find(:all, :include => {:task => :project}, :conditions => ["timeslices.created_at LIKE :month AND projects.id = :project_id", {:month => "#{@date.strftime('%Y')}-#{@date.strftime('%m')}%", :project_id => @project.id}]);

      @tasks = @project.tasks.find(:all, :conditions => ["(created_at LIKE :month) OR (id IN (:ids))", {:month => "#{@date.strftime('%Y')}-#{@date.strftime('%m')}%", :ids => @timeslices.collect(&:task).uniq.collect(&:id)}])
    end

    respond_to do |format|
      format.html
    end
  end

  def user_projects
    @staff = User.find(:all, :conditions => {:is_staff => 1})
  end

  def project_stakeholders
    @projects = Project.current
  end
end
