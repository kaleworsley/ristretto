class TimeslicesController < ApplicationController

  load_and_authorize_resource

  # TODO Make start time configurable per user
  DAYSTART = '08:00:00'

  before_filter :find_task, :only => [:new, :edit, :create, :index]
  before_filter :find_timeslice, :only => [:show, :edit, :update, :destroy, :delete]
  before_filter :set_dates, :only => [:index, :create, :timesheet]
  after_filter :copy_errors, :only => [:create, :update]

  skip_before_filter :require_login, :only => [:ical]

  # Ical feed for timeslices
  # TODO: this needs refactoring
  def ical
    user = User.find_by_single_access_token(params[:user_credentials])

    if params[:user]
      timeslices = User.find_by_name(params[:user]).timeslices.find(:all, :include => {:task => {:project => :customer}})
    else
      timeslices = Timeslice.find(:all, :include => {:task => {:project => :customer}})
    end

    if user && user.is_staff?
      cal = Icalendar::Calendar.new
      timeslices.each do |timeslice|
        event = Icalendar::Event.new
        event.start = timeslice.started.strftime("%Y%m%dT%H%M%S")
        event.end = timeslice.finished.strftime("%Y%m%dT%H%M%S")
        event.summary = timeslice.description
        event.organizer = "#{timeslice.user.full_name} <#{timeslice.user.email}>"
        event.description = "Timeslice for #{timeslice.task.project.customer}: #{timeslice.task.project}: #{timeslice.task}"
        cal.add_event(event)
      end
    end

    respond_to do |format|
      if user && user.valid?
        headers['Content-Type'] = "text/calendar; charset=UTF-8"
        cal.publish
        format.ics { render :text => cal.to_ical }
      else
        format.ics { render :nothing => true, :status => :forbidden }
      end
    end
  end


  def update_ar
    # FIXME: This should be a scope
    @timeslices = Timeslice.uninvoiced.reject {|t| t.task.project.fixed_price == true}
    @tasks = @timeslices.collect {|timeslice| timeslice.task}.uniq
    @projects = @tasks.collect {|task| task.project}.uniq
    @customers = @projects.collect {|project| project.customer}.uniq

    respond_to do |format|
      format.html
    end
  end

  def update_ar_save
    if params[:ar] =~ /[^\d+]/
      flash[:error] = 'Invalid AR number'
    else
      params[:include_task].each do |task_id|
        timeslices = Timeslice.find(params[:timeslice_ids][task_id])
        if timeslices.class == Timeslice
          timeslices = [timeslices]
        end
        timeslices.each do |timeslice|
          timeslice.ar = params[:ar].to_i
          if timeslice.save
            flash[:notice] = 'Updated AR'
          else
            flash[:error] = '<ul>'
            timeslice.errors.each do |field, message|
              flash[:error] += "Timeslice #" + timeslice.id.to_s + " - " + field + " - " + message + " - may be #" + timeslice.previous.id.to_s
            end
            flash[:error] += '</ul>'
          end
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to update_ar_path}
    end
  end

  def sales_order_tracker
    if params[:ar].blank?
      redirect_to invoice_tracker_path
    else
      redirect_to invoice_tracker_path(params[:ar])
    end
  end

  def invoice_tracker
    @recent = Timeslice.recent_invoices(current_user)
    @recent = @recent.select {|s| s.ar && s.ar != '' && s.ar != 0}
    if current_user.is_staff?
      if params[:invoice_val].blank? == false
        redirect_to invoice_tracker_path(:invoice => params[:invoice_val])
      end
      @invoice = params[:invoice]
      @timeslices = Timeslice.find(:all, :conditions => {:ar => @invoice}) || nil
    else
      if params[:invoice_val].blank? == false
        redirect_to invoice_tracker_path(:invoice => params[:invoice_val])
      end
      @invoice = params[:invoice]
      @timeslices = Timeslice.find(:all, :conditions => {:ar => @invoice, :task_id => current_user.current_projects_tasks_ids}) || nil
    end
  end

  def smart_add

  end

  def delete
    respond_to do |format|
      format.html
    end
  end

  def smart_create
    timeslice = Timeslice.new(params[:timeslice])
    timeslice.user = current_user

    respond_to do |format|
      if timeslice.save

        cookies.delete("timesliceDescription:#{timeslice.task.id.to_s}")
        cookies.delete("timesliceStarted:#{timeslice.task.id.to_s}")
        cookies.delete("timesliceFinished:#{timeslice.task.id.to_s}")
        cookies.delete("timesliceTimer:#{timeslice.task.id.to_s}")

        flash[:notice] = "Saved timeslice"
        format.html do
          if params[:return_to_task] == 'true'
            redirect_to timeslice.task
          else
            redirect_to timesheet_path(timeslice.started.strftime('%Y-%m-%d'))
          end

        end
        format.js { render :template => 'timeslices/smart_create'}
      else
        flash[:warning] = "Could not save timeslice: " + timeslice.errors.full_messages.to_s
        format.html {redirect_to timeslice.task}
        format.js
      end

    end
  end

  def timesheet
    unless params[:start].blank? && params[:end].blank?
      @timeslices = current_user.timeslices.by_date(Time.at(params[:start].to_i), Time.at(params[:end].to_i))
    else
      @timeslices = current_user.timeslices
    end

    @timeslice = Timeslice.new

    if @timeslices.length > 0
      @timeslice.started = @timeslices.last.finished
    else
      @timeslice.started = Time.zone.parse(@date.to_s + ' ' + DAYSTART)
    end

    @timeslice.finished = @timeslice.started + current_user.minute_step.minutes

    respond_to do |format|
      format.html
      format.xml  { render :xml => @timeslices }
      format.js do

      timeslice_collection = @timeslices.collect do |timeslice|
        {
        'id' => timeslice.id,
        'title' => timeslice.task.name,
        'description' => timeslice.description,
        'start' => timeslice.started.xmlschema,
        'end' => timeslice.finished.xmlschema,
        'allDay' => false,
        'className' => timeslice.chargeable ? 'chargeable' : 'non-chargeable'
        }

      end

      render :json => timeslice_collection
      end
    end
  end

  # GET /timeslices
  # GET /timeslices.xml
  def index
    if params[:task_id].nil?
      redirect_to timesheet_path
      return
    end
    @timeslices = Timeslice.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @timeslices }
    end
  end

  # GET /timeslices/1
  # GET /timeslices/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @timeslice }
    end
  end

  # GET /timeslices/new
  # GET /timeslices/new.xml
  def new
    if params[:task_id]
      @timeslice = @task.timeslices.build
    else
      if params[:start].present? && params[:end].present?
        @timeslice = Timeslice.new(:started => Time.at(params[:start].to_i), :finished => Time.at(params[:end].to_i))
      else
        @timeslice = Timeslice.new
      end
    end

    @timeslice.chargeable = true

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @timeslice }
    end
  end

  # GET /timeslices/1/edit
  def edit

  end

  # POST /timeslices
  # POST /timeslices.xml
  def create
    @timeslice = Timeslice.new(params[:timeslice])
    if @timeslice.started.to_i == @timeslice.finished.to_i
      @timeslice.finished = Time.now.utc.to_s(:db)
    end
    if @task.present?
      @timeslice.task = @task
    end
    @timeslice.user = current_user
    respond_to do |format|
      if @timeslice.save
        flash[:notice] = 'Timeslice was successfully created.'
        format.html do
          if @task.present?
            redirect_to(@task)
          else
            redirect_to(timesheet_path)
          end
        end
        format.xml  { render :xml => @timeslice, :status => :created, :location => @timeslice }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @timeslice.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  # PUT /timeslices/1
  # PUT /timeslices/1.xml
  def update
    respond_to do |format|
      if @timeslice.update_attributes(params[:timeslice])
        flash[:notice] = 'Timeslice was successfully updated.'
        format.html do
          redirect_to(@timeslice.task)
        end
        format.xml  { head :ok }
        format.js
      else
        flash[:error] = "Error saving timeslice: #{@timeslice.errors.full_messages}"
        format.html { render :action => "edit" }
        format.xml  { render :xml => @timeslice.errors, :status => :unprocessable_entity }
        format.js  { render :json => @timeslice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /timeslices/1
  # DELETE /timeslices/1.xml
  def destroy
    @timeslice.destroy

    respond_to do |format|
      format.html { redirect_to(@timeslice.task) }
      format.xml  { head :ok }
    end
  end


  private
    def find_task
      #@task = current_user.tasks.find(params[:task_id])
      #@task = current_user.tasks.find(params[:timeslice][:task_id]) if @task.nil?
      if params[:task_id].present?
        @task = Task.find(params[:task_id])
      else
        @task = nil
      end
    end

    def find_tasks
      @tasks = current_user.tasks
    end

    def find_timeslice
      @timeslice = Timeslice.find(params[:id])
    end
    def set_dates
      # If no date was passed, set today by default
      if params[:date]
        @date = Date.parse(params[:date])
      else
        @date = Date.today
      end

      # If no end date was passed, make the same as start date
      if params[:end_date]
        @end_date = Date.parse(params[:end_date])
        @multiday = true
      else
        @end_date = @date
        @multiday = false
      end
    end

    # The error messages for the native started and finished attributes
    # need to be copied to the started_time and finsihed_time attributes
    # if they are present.
    def copy_errors
      @timeslice.errors.add(:started_time,@timeslice.errors.on(:started)) if @timeslice.errors.on(:started_at)
      @timeslice.errors.add(:finished_time,@timeslice.errors.on(:finished)) if @timeslice.errors.on(:finished_at)
    end

    # Return the sum duration of a set of timeslices
    def total_duration(timeslices)
      timeslices.inject(0) do |total, timeslice|
         total + timeslice.duration
      end
    end

    # Return the filename for export actions.  Extension defaults to .csv
    def filename(prefix = '', extension = '.csv')
      datestr = @multiday ? "#{@date}_#{@end_date}" : "#{@date}"
      unless params[:task_id].blank?
        task = current_user.tasks.find(params[:task_id])
        prefix += task.safe_name + '-' unless task.nil?
      end
      prefix + datestr + extension
    end


end
