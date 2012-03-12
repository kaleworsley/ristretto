class TimeslicesController < ApplicationController
  DAYSTART = '09:00:00'

  before_filter :find_task, :only => [:new, :edit, :create, :index]
  before_filter :find_timeslice, :only => [:show, :edit, :update, :destroy, :delete]
  before_filter :set_dates, :only => [:index, :create, :timesheet]
  after_filter :copy_errors, :only => [:create, :update]

  def delete
    respond_to do |format|
      format.html
    end
  end

  def calendar
  
  end
  
  def add
   if params[:started].present? && params[:finished].present?
     @started = Time.at(params[:started].to_i)
     @finished = Time.at(params[:finished].to_i) 
   else
     @started = current_user.now
     @finished = current_user.now+(current_user.minute_step.to_i).minutes
   end

  end
  
  def add_save
    if params[:task_timeslice][:timetrackable_object].present?
      #split = params[:task_timeslice][:timetrackable_object].split('|')
      #params[:timeslice][:timetrackable_type] = split[0]
      #params[:timeslice][:timetrackable_id] = split[1]
      params[:timeslice][:timetrackable_object] = params[:task_timeslice][:timetrackable_object]
    elsif params[:ticket_timeslice][:timetrackable_object].present? && params[:ticket_timeslice][:timetrackable_object] =~ /^Ticket/
      #split = params[:ticket_timeslice][:timetrackable_object].split('|')
      #params[:timeslice][:timetrackable_type] = split[0]
      #params[:timeslice][:timetrackable_id] = split[1]
      params[:timeslice][:timetrackable_object] = params[:ticket_timeslice][:timetrackable_object]
    elsif params[:ticket_timeslice][:timetrackable_object].present? && params[:ticket_timeslice][:timetrackable_object] =~ /^(Customer|Project)/
      @ticket = Ticket.create(:ticketable_object => params[:ticket_timeslice][:timetrackable_object], :description => params[:timeslice][:description])
      #split = params[:ticket_timeslice][:timetrackable_object].split('|')
      #@ticket = Ticket.create(:ticketable_type => split[0], :ticketable_id => split[1], :description => params[:timeslice][:description])
      #params[:timeslice][:timetrackable_type] = 'Ticket'
      #params[:timeslice][:timetrackable_id] = @ticket.id
      params[:timeslice][:timetrackable_object] = @ticket.timetrackable_object
    end

    @timeslice = Timeslice.new(params[:timeslice])
    if @timeslice.started.to_i == @timeslice.finished.to_i
      @timeslice.finished = Time.now.utc.to_s(:db)
    end

    @timeslice.user = current_user
    
    respond_to do |format|
      if @timeslice.save
        flash[:notice] = 'Timeslice was successfully created.'
        format.html { redirect_to(add_timeslice_path) }
        format.xml  { render :xml => @timeslice, :status => :created, :location => @timeslice }
        format.js
      else
        flash[:error] =  @timeslice.inspect
        format.html { render :action => "add" }
        format.xml  { render :xml => @timeslice.errors, :status => :unprocessable_entity }
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
        'title' => timeslice.timetrackable.name,
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
      if params[:started].present? && params[:finished].present?
        @timeslice = Timeslice.new(:started => Time.at(params[:started].to_i), :finished => Time.at(params[:finished].to_i))
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
    split = params[:timeslice][:timetrackable_object].split('|')
    params[:timeslice][:timetrackable_type] = split[0]
    params[:timeslice][:timetrackable_id] = split[1]
    
    @timeslice = Timeslice.new(params[:timeslice])
    if @timeslice.started.to_i == @timeslice.finished.to_i
      @timeslice.finished = Time.now.utc.to_s(:db)
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
    if params[:timeslice][:timetrackable_object].present?
      split = params[:timeslice][:timetrackable_object].split('|')
      params[:timeslice][:timetrackable_type] = split[0]
      params[:timeslice][:timetrackable_id] = split[1]
    end

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
