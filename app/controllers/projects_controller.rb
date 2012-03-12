class ProjectsController < ApplicationController
  before_filter :find_project, :only => [:edit, :delete, :show, :update, :destroy, :uninvoiced, :invoice, :time]
  before_filter :find_customer, :only => [:index, :new, :create]
  before_filter :find_projects, :only => [:index]

  skip_before_filter :require_login, :only => [:ical]

  def delete

  end
  
  def time
  end

  def uninvoiced
    begin
      @invoices = Xero.Invoice.all(:where => {:type => 'ACCREC', :status => 'DRAFT'}).reject {|i| i.contact.contact_id != @project.customer.xero_contact_id}
    rescue Exception => msg
      @invoices = []
      flash[:error] = 'Cannot connect to Xero.'
      logger.debug "Xero error: #{msg}"
    end
  end
  
  def invoice
    if params[:issue_date].blank?
      @date = Date.today
    else
      @date = Date.parse(params[:issue_date])
    end

    if params[:due_date].blank?
      @due_date = @date + 30.days
    else
      @due_date = Date.parse(params[:due_date])
    end

    if params[:invoice][:invoice_id].blank?
      @new_invoice = true
      @invoice = Xero.Invoice.build(:type => 'ACCREC', :contact => @project.customer.xero_customer)
    else
      @new_invoice = false
      @invoice = Xero.Invoice.find(params[:invoice][:invoice_id])
    end

    params[:items].each do |id, val|
      @invoice.add_line_item(:description => val[:description], :quantity => val[:hours].to_f, :unit_amount => @project.rate.to_f) if val[:include]
    end

    @invoice.date = @date
    @invoice.due_date = @due_date
    @invoice.save
    @invoice_id = @invoice.invoice_id
    @invoice_number = @invoice.invoice_number

    params[:items].each do |id, val|
      if val[:include]
        timeslice_ids = val[:timeslice_ids].split(',')
        timeslice_ids.each do |timeslice_id|
          Timeslice.find(timeslice_id).update_attributes(:invoice => @invoice_number)
        end
      end
    end
    
    respond_to do |format|
      if @new_invoice
        flash[:notice] = '<a href="https://go.xero.com/AccountsReceivable/View.aspx?InvoiceId=' + @invoice_id + '">Your invoice</a> was successfully created.'
      else
        flash[:notice] = '<a href="https://go.xero.com/AccountsReceivable/View.aspx?InvoiceId=' + @invoice_id + '">Your invoice</a> was successfully updated.'
      end
      format.html { redirect_to(@project) }
    end  
  end

  # GET /projects
  # GET /projects.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.xml  { render :xml => @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = @customer.projects.new

		3.times { @project.tasks.build }

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
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
    def find_project
      @project = Project.find(params[:id])
    end

    def find_projects
      if @customer.nil?
        @index_scope = params[:index_scope]
        case params[:index_scope]
        when :current
          @projects = Project.page(params[:page], {:state => 'current'})
        when :proposed
          @projects = Project.page(params[:page], {:state => 'proposed'})
        when :complete
          @projects = Project.page(params[:page], {:state => 'complete'})
        when :postponed
          @projects = Project.page(params[:page], {:state => 'postponed'})
        when :development
          @projects = Project.page(params[:page], {:kind => 'development'})
        when :support
          @projects = Project.page(params[:page], {:kind => 'support'})
        else
          @projects = Project.page(params[:page])
        end
      else
        @projects = @customer.projects.page(params[:page])
      end
    end

    def find_customer
      @customer = Customer.find(params[:customer_id]) if params[:customer_id]
    end
end
