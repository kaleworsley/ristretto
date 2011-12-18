include ActionView::Helpers::DateHelper
  # TODO: Rename poorly-named methods.
class User < ActiveRecord::Base
  searchable do
    text :full_name, :email
  end
  # Create revisions
  versioned :except => [:perishable_token, :last_request_at]

  validates_presence_of :full_name
  validates_presence_of :email
  validates_uniqueness_of :full_name
  validates_uniqueness_of :email

  serialize :ignore_mail, Hash

  acts_as_authentic do |config|
    # If passwords are found in plain MD5 crypt (e.g. from a Drupal import)
    # they will be updated to the default encryption scheme on successful
    # login
    config.transition_from_crypto_providers = [Authlogic::CryptoProviders::MD5]
  end

  has_many :tasks
  has_many :assigned_tasks, :class_name => 'Task', :foreign_key => 'assigned_to_id'

  has_many :timeslices do
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
  has_and_belongs_to_many :mailouts

  def staff
    User.all
  end


  # Adds an object to a users ignore mail list
  def ignore_mail_from(instance)
    return true if ignore_mail_from?(instance)
    self.ignore_mail = {} if self.ignore_mail.nil?
    unless self.ignore_mail.include? instance.class.to_s
      self.ignore_mail[instance.class.to_s] = []
    end
    self.ignore_mail[instance.class.to_s].push(instance.to_param)
    self.save
  end

  # Removes an object from a users ignore mail list
  def receive_mail_from(instance)
    return true if receive_mail_from?(instance)
    self.ignore_mail[instance.class.to_s].delete(instance.to_param) != nil
    self.save
  end

  # Checks for an object in a users ignore mail list
  def ignore_mail_from?(instance)
    self.ignore_mail = {} if self.ignore_mail.nil?
    if self.ignore_mail.include? instance.class.to_s
      if self.ignore_mail[instance.class.to_s].include? instance.to_param
        true
      else
        false
      end
    else
      false
    end
  end

  def current_projects
    projects.current
  end  

  def dashboard_panels
    panels = ['project_list', 'timesheet']
    slices = []
    
    panels.each_slice(2) {|slice| slices.push(slice) }
    
    slices
  end

  def receive_mail_from?(instance)
    !ignore_mail_from?(instance)
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
    "#{last_name}, #{first_name} (#{email})"
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

  # Returns all projects that the user is a member of
  def all_projects
    current_projects
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
