class TasksController < ApplicationController
  DAYSTART = '09:00:00'

  before_filter :find_task, :only => [:edit, :delete, :show, :update, :destroy]
  before_filter :find_project
  before_filter :find_customer
  before_filter :find_tasks, :only => [:index]

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
    @task = @project.tasks.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.xml
  def create
    @task = Task.new(params[:task])
    @task.project = @project
    @task.weight = @project.tasks.size + 1

    respond_to do |format|
      if @task.save
        flash[:notice] = 'Task was successfully created.'
        format.html { redirect_to(@project) }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
        format.js   { render :partial => 'errors' }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.xml
  def update
    destination = (params[:destination].present?) ? params[:destination] : @task 
    @task.attributes = params[:task]

    respond_to do |format|
      if @task.save
        @task.project.touch

        flash[:notice] = 'Task was successfully updated.'
        format.html { redirect_to(destination) }
        format.xml  { head :ok }
      else
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
