class CustomersController < ApplicationController
  before_filter :find_customer, :only => [:edit, :delete, :show, :update, :destroy]


  def xero
    @xero_contact_id = params[:xero_contact_id]
    if @xero_contact_id.present?
      @customer = Customer.find_by_xero_contact_id(@xero_contact_id)
      if @customer.present?
        redirect_to @customer
      else
        begin
          @xero_contact = Xero.Contact.find(@xero_contact_id)
        rescue Exception => msg
          logger.debug "Xero error: #{msg}"
          @xero_contact = nil
          flash[:notice] = 'Could not find customer.'
          redirect_to customers_path
        end
        if @xero_contact.present?
          redirect_to new_customer_path(:name => @xero_contact.name, :xero_contact_id => @xero_contact_id)
        end
      end
    else
      flash[:notice] = 'Could not find customer.'
      redirect_to customers_path
    end
  end

  def delete

  end

  def missing
    @customer_names = Customer.all.map(&:name)
    begin
      @xero_customers = Xero.Contact.all(:where => {:is_customer => true}).reject {|c| @customer_names.include? c.name }
    rescue Exception => msg
      logger.debug "Xero error: #{msg}"
      @xero_customers = nil
      flash[:error] = 'Cannot connect to Xero.'
    end
  end

  def index
    respond_to do |format|
      format.html { @customers = Customer.page(params[:page]) }
      format.js { @customers = Customer.page(params[:page]) }
      format.xml  { render :xml => Customer.all }
      format.json  { render :json => Customer.all }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @customer }
      format.json  { render :json => @customer }
    end
  end

  def new
    begin
      @xero_customers = Xero.Contact.all
    rescue Exception => msg
      logger.debug "Xero error: #{msg}"
      @xero_customers = nil
      flash[:error] = 'Cannot connect to Xero.'
    end

    @customer = Customer.new
    if params[:name].present?
      @customer.name = params[:name]
    end

    if params[:xero_contact_id].present?
      @customer.xero_contact_id = params[:xero_contact_id].downcase
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @customer }
    end
  end

  # GET /customers/1/edit
  def edit
    begin
      @xero_customers = Xero.Contact.all
    rescue Exception => msg
      logger.debug "Xero error: #{msg}"
      @xero_customers = nil
      flash[:error] = 'Cannot connect to Xero.'
    end
  end

  # POST /customers
  # POST /customers.xml
  def create
    @customer = Customer.new(params[:customer])
    respond_to do |format|
      if @customer.save
        flash[:notice] = 'Customer was successfully created.'
        format.html { redirect_to(@customer) }
        format.xml  { render :xml => @customer, :status => :created, :location => @customer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /customers/1
  # PUT /customers/1.xml
  def update
    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        flash[:notice] = 'Customer was successfully updated.'
        format.html { redirect_to(@customer) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.xml
  def destroy
    @customer.destroy

    respond_to do |format|
      format.html { redirect_to(customers_url) }
      format.xml  { head :ok }
    end
  end

  private

  def find_customer
    @customer = Customer.find(params[:id])
  end
end
