class CommentsController < ApplicationController

  load_and_authorize_resource :through => :task

  before_filter :find_comment, :only => [:edit, :show, :update, :destroy, :delete]
  before_filter :find_task, :only => [:index, :new, :create]
  after_filter :new_attachments, :only => [:create, :update]

  # GET /comments
  # GET /comments.xml
  def index
    @comments = @task.comments

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.xml
  def new
    @comment = @task.comments.build

    @attachment = Attachment.new

    if params[:task]
      @comment.task_id = params[:task]
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @task = @comment.task
    @attachment = Attachment.new
  end

  # POST /comments
  # POST /comments.xml
  def create
    @comment = @task.comments.build(params[:comment])
    @comment.user = current_user

    respond_to do |format|
      if @comment.save

        @comment.task.project.update_attributes(:updated_at => DateTime.now.to_s(:db));
        @comment.task.project.save
        # Send notifications to recipients
        if params[:notify][:notify]
          @comment.task.recipients.reject {|u| u == @comment.user}.each do |recipient|
            Mailer.deliver_task_comment(@comment, recipient)
          end
        end
        flash[:notice] = 'Comment was successfully created.'
        format.html { redirect_to(@task) }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
        format.js
      else
        @attachment = Attachment.new
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    respond_to do |format|
      if @comment.update_attributes(params[:comment])

        flash[:notice] = 'Comment was successfully updated.'
        format.html { redirect_to(@comment.task) }
        format.xml  { head :ok }
      else
        @attachment = Attachment.new
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment.destroy
    flash[:notice] = 'Comment has been removed'
    respond_to do |format|
      format.html { redirect_to(@comment.task) }
      format.xml  { head :ok }
    end
  end

  private

  def new_attachments
    new_attachments = params[:new_attachments]
    unless new_attachments.nil?
      new_attachments.each do |attachment|
        attachment['attachable_id'] = @comment.id
        attachment['user_id'] = current_user.id
        attachment['attachable_type'] = @comment.class.to_s
        attachment['attachable'] = @comment
        Attachment.create(attachment)
      end
    end

  end

  def find_comment
    @comment = Comment.find(params[:id])
  end

  def find_task
    @task = Task.find(params[:task_id])
  end
end
