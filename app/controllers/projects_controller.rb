class ProjectsController < ApplicationController
  before_filter :find_project, :only => [:edit, :delete, :show, :update, :destroy]
  before_filter :find_customer, :only => [:index, :new, :create]
  before_filter :find_projects, :only => [:index]
  after_filter :new_attachments, :only => [:create, :update]

  skip_before_filter :require_login, :only => [:ical]

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
    @task = @project.tasks.new
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

		3.times { @project.tasks.build }
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
		@project.tasks.build
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = @customer.projects.build(params[:project])

    respond_to do |format|
      if @project.save
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
        @projects = Project.page(params[:page])
      else
        @projects = @customer.projects.page(params[:page])
      end
    end

    def find_customer
      @customer = Customer.find(params[:customer_id]) if params[:customer_id]
    end
end
