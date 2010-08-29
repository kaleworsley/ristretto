class StakeholdersController < ApplicationController

  load_and_authorize_resource

  before_filter :find_stakeholder, :only => [:show, :edit, :update, :destroy, :delete]
  before_filter :find_project, :only => [:show, :edit, :new, :index, :create, :delete]

  def delete
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /stakeholders
  # GET /stakeholders.xml
  def index
    @stakeholders = @project.stakeholders

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stakeholders }
    end
  end

  # GET /stakeholders/new
  # GET /stakeholders/new.xml
  def new
    @stakeholder = Stakeholder.new
    @valid_users = User.all.sort_by(&:full_name) - @project.users

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stakeholder }
    end
  end

  # GET /stakeholders/1/edit
  def edit

  end

  # POST /stakeholders
  # POST /stakeholders.xml
  def create
    @stakeholder = Stakeholder.new(params[:stakeholder])
    @stakeholder.project = @project

    respond_to do |format|
      if @stakeholder.save
        flash[:notice] = 'Stakeholder was successfully created.'
        format.html { redirect_to(@stakeholder.project) }
        format.xml  { render :xml => @stakeholder, :status => :created, :location => @stakeholder }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stakeholder.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stakeholders/1
  # PUT /stakeholders/1.xml
  def update
    respond_to do |format|
      if @stakeholder.update_attributes(params[:stakeholder])
        flash[:notice] = 'Stakeholder was successfully updated.'
        format.html { redirect_to(@stakeholder.project) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stakeholder.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stakeholders/1
  # DELETE /stakeholders/1.xml
  def destroy
    @stakeholder.destroy

    respond_to do |format|
      format.html { redirect_to(@stakeholder.project) }
      format.xml  { head :ok }
    end
  end

  private

  def find_stakeholder
    @stakeholder = Stakeholder.find(params[:id])
  end

  def find_project
    unless params[:project_id].nil?
      @project = Project.find(params[:project_id])
    else
      @project = @stakeholder.project
    end
  end
end
