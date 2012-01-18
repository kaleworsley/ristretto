class Customer < ActiveRecord::Base
  after_create :xero_create
  after_update :xero_update

  searchable do
    text :name
  end

  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :projects, :dependent => :destroy
  has_many :tickets, :as => :ticketable
  
  def Customer.with_projects_tasks
    Customer.find(:all, :include => {:projects => :tasks}).reject {|c| c.projects_tasks.size == 0}
  end

  def xero_customer
    if xero_contact_id.present?
      @contact ||= Xero.Contact.find(xero_contact_id)
    end
  end
  
  def xero_customer?
    xero_customer.present?
  end

  def xero_url
    "https://go.xero.com/Contacts/View.aspx?contactID=#{xero_contact_id}"
  end

  def invoices
    @invoices ||= Xero.Invoice.all(:where => {:type => 'ACCREC'}).reject {|i| i.contact.contact_id != xero_contact_id}    
  end

  def support_projects
    Project.find(:all, :conditions => {:kind => 'support', :customer_id => id})
  end

  def development_projects
    Project.find(:all, :conditions => {:kind => 'development', :customer_id => id})
  end

  def projects_tasks
    project_task = Struct.new(:name, :id)
    projects.map {|p| p.tasks.map {|t| project_task.new("#{p.name}: #{t.name}", t.timetrackable_id) }}.flatten
  end

  # By default, sort all finders by name
  def self.find(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options[:order] = 'name asc' unless options.include? :order
    args.push(options)
    super
  end

  def ticketable_object
    "Customer|#{id}"
  end

  def to_s
    name
  end
  
  def to_option
    [name, ticketable_object]
  end

  def self.page(page)
    paginate :per_page => 50, :page => page, :order => 'name'
  end
  
  private

  def xero_update
    if xero_customer?
      if xero_customer.name != name
        xero_customer.name = name
        xero_customer.save
      end
    else
      xero_create
    end
  end
  
  def xero_create
    if xero_contact_id.blank?
      @contact ||= Xero.Contact.first(:where => {:name => name, :contact_status => 'ACTIVE'})
      if @contact.blank?
        @contact = Xero.Contact.build(:name => name)
        @contact.save
      end
      update_attributes(:xero_contact_id => @contact.contact_id)
    end
  end
end
