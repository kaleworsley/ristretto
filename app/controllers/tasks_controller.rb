class TasksController < ApplicationController

  load_and_authorize_resource

  # TODO Make start time configurable per user
  DAYSTART = '08:00:00'

  before_filter :find_task, :only => [:edit, :delete, :show, :update, :destroy, :enable_mail, :disable_mail]
  before_filter :find_project
  before_filter :find_customer
  before_filter :find_tasks, :only => [:index]
  after_filter :new_attachments, :only => [:create, :update]

  def import
    
  end

  def import_save
    @tasks =  params[:tasks]
    if @tasks.present?
      @tasks.split("\n").each do |task|
        t = @project.tasks.build({:name => task.strip})
        t.user = current_user
        t.save
        logger.debug t.errors.full_messages.inspect
      end
      redirect_to @project
      else 
      flash[:warning] = 'Task import was empty.'
      render :action => "import"
    end
  end

  # Enable email notifications for this task
  def enable_mail
    current_user.receive_mail_from(@task)
    redirect_to @task
  end

  # Disable email notifications for this task
  def disable_mail
    current_user.ignore_mail_from(@task)
    redirect_to @task
  end

  def delete

  end

  # GET /tasks
  # GET /tasks.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.xml
  def show
    @comment = Comment.new({:task => @task})
    @attachment = Attachment.new
    @timeslices = current_user.timeslices.by_date(DateTime.now.beginning_of_day, DateTime.now.end_of_day)
    @timeslice = Timeslice.new

    if @timeslices.size > 0
      @timeslice.started = @timeslices.last.finished
    else
      @timeslice.started = Time.zone.parse(@date.to_s + ' ' + DAYSTART)
    end

    @timeslice.finished = @timeslice.started + current_user.minute_step.minutes

    @attachment = Attachment.new

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @task }
      format.js do
        task = {:task => {:description => help.markdown(@task.description)}}
        render :json => task
      end
    end
  end

  # GET /tasks/new
  # GET /tasks/new.xml
  def new
    @task = Task.new(:project => @project)
    @task.user = current_user

    @attachment = Attachment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    @attachment = Attachment.new
    @stakeholders = @task.project.stakeholders.collect {|stakeholder| stakeholder.user}
  end

  # POST /tasks
  # POST /tasks.xml
  def create
    @task = Task.new(params[:task])
    @task.user = current_user
    @task.project = @project
    @task.weight = @project.tasks.size + 1

    respond_to do |format|
      if @task.save
        @task.project.touch

        flash[:notice] = 'Task was successfully created.'
        format.html { redirect_to(@project) }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
        format.js
      else
        @attachment = Attachment.new
        format.html { render :action => "new" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
        format.js   { render :partial => 'errors' }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.xml
  def update
    respond_to do |format|
      if @task.update_attributes(params[:task])

        @task.project.touch

        flash[:notice] = 'Task was successfully updated.'
        format.html { redirect_to(@task) }
        format.xml  { head :ok }
        format.js do
          task = {:task => {:description => help.markdown(@task.description), :cypher => @task.assigned_to.try(:initials) || '---', :state => @task.state, :assigned_to => @task.assigned_to.try(:full_name) || 'Un-assigned'}}
          render :json => task
        end
      else
        @attachment = Attachment.new
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.xml
  def destroy
    @task.destroy

    respond_to do |format|
      format.html { redirect_to(@task.project) }
      format.xml  { head :ok }
    end
  end

  private
    def new_attachments
      new_attachments = params[:new_attachments]
      unless new_attachments.nil?
        new_attachments.each do |attachment|
          attachment['attachable_id'] = @task.id
          attachment['user_id'] = current_user.id
          attachment['attachable_type'] = @task.class.to_s
          attachment['attachable'] = @task
          Attachment.create(attachment)
        end
      end
    end

    def find_task
      @task = Task.find(params[:id])
    end

    def find_tasks
      if @project.nil?
        @tasks = Task.page(params[:page])
      else
        @tasks = @project.tasks.page(params[:page])
      end
    end

    def find_project
      if params[:project_id].present?
        @project = Project.find(params[:project_id])
      elsif @task.present?
        @project = @task.project
      end
    end

    def find_customer
      if @project
        @customer = @project.customer
      end
    end
end
