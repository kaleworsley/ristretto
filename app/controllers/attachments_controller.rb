class AttachmentsController < ApplicationController
  before_filter :find_attachment, :only => [:edit, :delete, :show, :update, :destroy, :download]

  def download
    #send_file(@attachment.file.path, {:type => @attachment.file_content_type, :filename => @attachment.file_file_name})
    send_file(@attachment.file.path, {:type => @attachment.file_content_type, :disposition => 'inline', :filename => @attachment.file_file_name})
  end

  def show
    #send_file(@attachment.file.path, {:type => @attachment.file_content_type, :disposition => 'inline', :filename => @attachment.file_file_name})
  end

  def new
    @attachment = Attachment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @attachment }
    end

  end

  def create
    @attachment = Attachment.new(params[:attachment])
    @attachment.user = current_user
    respond_to do |format|
      if @attachment.save
        flash[:notice] = 'Attachment was successfully created.'
        format.html { redirect_to(@attachment.attachable) }
        format.xml  { render :xml => @attachment, :status => :created, :location => @attachment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @attachment.errors, :status => :unprocessable_entity }
      end
    end

  end


  def destroy
    @attachment.destroy

    respond_to do |format|
      format.html { redirect_to(attachments_url) }
      format.xml  { head :ok }
    end
  end

  def delete
  end

  def index
    if params[:project_id].present?
      @project = Project.find(params[:project_id])
      @attachments = @project.attachments
    else
      @attachments = Attachment.page(params[:page])
    end

    respond_to do |format|
      format.html
      format.xml  { render :xml => @attachments }
    end
  end

  private
    def find_attachment
      @attachment = Attachment.find(params[:id])
    end
end
