class ProjectsController < ApplicationController

  load_and_authorize_resource

  before_filter :find_project, :only => [:edit, :delete, :show, :update, :destroy, :update_task_order, :watch, :enable_mail, :disable_mail]
  before_filter :find_customer, :only => [:index, :new, :create]
  before_filter :find_projects, :only => [:index]
  after_filter :new_attachments, :only => [:create, :update]

  skip_before_filter :require_login, :only => [:ical]

  # Ical feed for project deadlines
  # TODO: this needs refactoring
  def ical
    user = User.find_by_single_access_token(params[:user_credentials])

    if user
      if user.is_staff?
        projects = Project.current
      else
        projects = user.current_projects.current
      end
    end

    if projects
      cal = Icalendar::Calendar.new

      projects.each do |project|
        if project.deadline.present?
          event = Icalendar::Event.new
          event.start = project.deadline
          event.summary = "#{project} deadline"
          cal.add_event(event)
        end
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

  # Enable email notifications for this project
  def enable_mail
    current_user.receive_mail_from(@project)
    redirect_to @project
  end

  # Disable email notifications for this project
  def disable_mail
    current_user.ignore_mail_from(@project)
    redirect_to @project
  end

  def project_order
    respond_to do |format|
      format.html
    end
  end

  def update_project_order
    projects = params[:project_ids]
    order = params[:project_orders]
    state = params[:project_states]

    projects.each_with_index do |project_id, key|
      project = Project.find(project_id)
      project.weight = order[key]
      project.state = state[key]
      project.save
    end
    flash[:notice] = 'Projects were successfully updated.'
    @projects = Project.find(projects)
    respond_to do |format|
      format.html { redirect_to project_order_path }
      format.js
    end
  end

  def update_task_order
    @tasks = params[:task_ids]
    @order = params[:task_orders]
    @state = params[:task_states]
    flash[:notice] = 'Tasks were successfully updated.'
    @tasks.each_with_index do |task_id, key|
      task = Task.find(task_id)
      task.weight = @order[key]
      task.state = @state[key]
      task.save
    end

    @project.update_attributes(:updated_at => DateTime.now.to_s(:db));
    @project.save

    respond_to do |format|
      format.html { redirect_to project_path(@project) }
      format.js
    end

  end

  def watch
  end

  def delete

  end

  # GET /projects
  # GET /projects.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @task = @project.tasks.build
    @attachment = Attachment.new

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
      format.js do
        project = {
          :project => {
            :name => @project.name,
            :id => @project.id,
            :todo => @project.todo.length,
            :doing => @project.doing.length,
            :done => @project.done.length
            }
          }
        render :json => project
      end
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new
    @attachment = Attachment.new

    if params[:customer]
      @project.customer_id = params[:customer]
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @attachment = Attachment.new

  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = @customer.projects.build(params[:project])
    @project.user = current_user

    respond_to do |format|
      if @project.save

        @project.add_stakeholder(current_user, params['stakeholder_role']) if params['is_member']
        flash[:notice] = 'Project was successfully created.'
        format.html { redirect_to(@project) }
        format.xml  { render :xml => @project, :status => :created, :location => @project }
      else
        @attachment = Attachment.new
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = 'Project was successfully updated.'
        format.html { redirect_to(@project) }
        format.xml  { head :ok }
      else
        @attachment = Attachment.new
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(@project.customer) }
      format.xml  { head :ok }
    end
  end

  private
    def new_attachments
      new_attachments = params[:new_attachments]
      unless new_attachments.nil?
        new_attachments.each do |attachment|
          attachment['attachable_id'] = @project.id
          attachment['user_id'] = current_user.id
          attachment['attachable_type'] = @project.class.to_s
          attachment['attachable'] = @project
          Attachment.create(attachment)
        end
      end
    end

    def find_project
      @project = Project.find(params[:id])
    end

    def find_projects
      if @customer.nil?
        @projects = current_user.current_projects.page(params[:page])
      else
        @projects = @customer.projects.page(params[:page])
      end
    end

    def find_customer
      @customer = Customer.find(params[:customer_id]) if params[:customer_id]
    end
end
