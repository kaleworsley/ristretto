include ActionView::Helpers::DateHelper
  # TODO: Rename poorly-named methods.
class User < ActiveRecord::Base
  searchable do
    text :full_name, :email
  end

  validates_presence_of :full_name
  validates_presence_of :email
  validates_uniqueness_of :full_name
  validates_uniqueness_of :email

  acts_as_authentic

  has_many :timeslices, :dependent => :destroy do
    # Get all chargeable timeslices or all chargeable timeslices on a date
    # or all chargeable timeslices between a range, for a user
    def chargeable(start = nil, finish = nil)
      if start.nil? && finish.nil?
        return find_all {|t| t.chargeable}
      elsif finish.nil? && !start.nil?
        finish = start
      end
      by_date(start, finish).find_all {|t| t.chargeable}
    end

    # Get all non-chargeable timeslices or all non-chargeable timeslices on a date
    # or all non-chargeable timeslices between a range, for a user
    def non_chargeable(start = nil, finish = nil)
      if start.nil? && finish.nil?
        return find_all {|t| !t.chargeable}
      elsif finish.nil? && !start.nil?
        finish = start
      end
      by_date(start, finish).find_all {|t| !t.chargeable}
    end
  end
  
  has_and_belongs_to_many :projects, :uniq => true

  DASHBOARD_PANELS = ['project_list', 'timesheet', 'customer_list', 'new_customer']

  serialize :panels

  def staff
    User.all
  end


  def customers
    projects.map(&:customer).uniq
  end

  def current_projects
    projects.current
  end  
  def dashboard_panels
    if panels.present?
      [] + panels.sort_by {|v,k| k}.map{|v| v[0] }.to_a
    else
      []
    end
  end

  def now
    Time.at((DateTime.now.to_i.to_f/(60*minute_step)).round*(60*minute_step)).to_datetime
  end

  # Send password reset instructions
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Mailer.deliver_password_reset_instructions(self)
  end

  # Minute steps
  def User.minute_steps_for_select
    [1, 5, 10, 15]
  end

  # Paginate
  def self.page(page)
    paginate :per_page => 50, :page => page
  end

  def to_s
    full_name
  end

  def name
    full_name
  end

  def for_select_box
    "#{full_name} (#{email})"
  end

  # Initials e.g. FL
  def initials
    'TODO'
  end

  def is_staff
    true
  end


  # Is a user a staff member?
  def is_staff?
    true
  end


  def tasks_for_select
    current_projects_tasks.group_by(&:customer).map {|customer, tasks| [customer.name, tasks.map {|t|["#{t.project.name} : #{t.name}", t.timetrackable_object]}] }
  end
  
  def timetrackable_for_select
  @timetrackable = []
    @customers = Customer.all.each do |c|
     @items = [] + (c.tickets.map {|t| t.to_option })
     c.support_projects.each do |p|
       @items += [p.to_option] + (p.tickets.map {|t| t.to_option })
     end
     
     c.development_projects.each do |p|
       @items += [] + (p.tasks.map {|t| t.to_option })
     end
     
       
     @timetrackable.push([c.name, @items.reject(&:blank?)])
    end
    @timetrackable.sort_by {|o| o[0] }
  end

  # Returns all projects that the user is a member of
  def all_projects
    projects
  end

  # Returns an array of project ids to which this user is associated
  def current_projects_ids
    current_projects.map(&:id)
  end

  def current_customers_ids
    current_customers.map(&:id)
  end

  def current_projects_tasks_ids
    current_projects_tasks.map(&:id)
  end

  # Returns an array of all timeslices assigned to any project on which this
  # user is a member
  def current_projects_timeslices(params = nil)
    options = {
      :joins => { :task => :project },
      :conditions => {:projects => {:id => current_projects_ids}}
    }
    options.merge!(params) unless params.nil?

    Timeslice.all options
  end

  # Return the most recent timeslices assigned to any project on which this
  # user is a member, in reverse date order.  An options limit can be
  # supplied, the default is 10
  def current_projects_recent_timeslices(limit = 10)
    current_projects_timeslices(:order => 'started DESC', :limit => limit)
  end

  def current_projects_recent_tasks(limit = 10)
    current_projects_tasks(:order => 'created_at DESC', :limit => limit)
  end

  def current_projects_recent_projects(limit = 10)
    current_projects.find(:all, :order => 'created_at DESC', :limit => limit)
  end

  def current_projects_recent_attachments(limit = 10)
    current_projects_attachments(:order => 'created_at DESC', :limit => limit)
  end

  def current_customers_recent_customers(limit = 10)
    current_customers_customers(:order => 'created_at DESC', :limit => limit)
  end

  # Returns an array of all tasks of any project on which this
  # user is a member
  def current_projects_tasks(params = nil)
    options = {
      :conditions => {:project_id => current_projects_ids},
      :include => :timeslices
    }
    options.merge!(params) unless params.nil?

    Task.all options
  end


  def current_customers_customers(params = nil)
    options = {
      :conditions => {:id => current_customers_ids},
    }
    options.merge!(params) unless params.nil?

    Customer.all options
  end

  def current_projects_attachments(params = nil)
    options = {
      :conditions => ["(attachable_type = 'Task' AND attachable_id IN (?)) OR (attachable_type = 'Project' AND attachable_id IN (?)))", current_projects_tasks_ids, current_projects_ids],
    }
    options.merge!(params) unless params.nil?

    ::Attachment.all options
  end

  def current_customers
    current_projects.collect(&:customer).uniq
  end

  def timeslice_activity_items(limit = 10)
    current_projects_recent_timeslices(limit).collect(&:activity_item)
  end

  def task_activity_items(limit = 10)
    current_projects_recent_tasks(limit).collect(&:activity_item)
  end

  def project_activity_items(limit = 10)
    current_projects_recent_projects(limit).collect(&:activity_item)
  end

  def attachment_activity_items(limit = 10)
    current_projects_recent_attachments(limit).collect(&:activity_item)
  end

  def customer_activity_items(limit = 10)
    current_customers_recent_customers(limit).collect(&:activity_item)
  end

  def activity_items(limit = 10)
    task_activity_items(limit) +
    timeslice_activity_items(limit) +
    project_activity_items(limit) +
    attachment_activity_items(limit) +
    customer_activity_items(limit)
  end
end
