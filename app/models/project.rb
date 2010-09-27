class Project < ActiveRecord::Base
  # Create revisions
  versioned

  validates_presence_of :name
  validates_presence_of :customer_id
  validates_numericality_of :estimate, :greater_than => 0, :allow_nil => true

  belongs_to :customer
  belongs_to :user
  has_many :tasks, :dependent => :destroy
  has_many :stakeholders, :dependent => :destroy
  has_many :users, :through => :stakeholders
  #NOTE: ":class_name => '::Attachment''" is required. There is a bug in paperclip
  #see: http://thewebfellas.com/blog/2008/11/2/goodbye-attachment_fu-hello-paperclip#comment-2415
  has_many :attachments, :as => :attachable, :dependent => :destroy, :class_name => '::Attachment'

  # Project states
  STATES = ['proposed', 'current', 'postponed', 'complete']

  # Project estimate units
  ESTIMATE_UNITS = ['hours', 'points']

  STATES.each do |state|
    named_scope state, :conditions => { :state => state }, :include => [{:tasks => :timeslices}, :customer, :stakeholders], :order => 'weight asc'
  end

  # Returns true if a given user is the project manager of this project
  def mine?(user)
    stakeholders.project_manager(user).present?
  end

  # Return a hash of available project states suitable for the select helper
  def Project.states_for_select
    STATES.collect { |state| [state.humanize, state] }
  end

  # Project states
  def Project.states
    STATES
  end

  # Project estimate units
  def Project.estimate_units
    ESTIMATE_UNITS
  end

  # Return a hash of available project estimate units suitable for the select helper
  def Project.estimate_units_for_select
    ESTIMATE_UNITS.collect { |unit| [unit.humanize, unit]}
  end

  def self.find(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    if not options.include? :include
      options[:include] = :tasks
    end
    args.push(options)
    super
  end

  def to_s
    name
  end

  # Collection of all timeslice of that belong to tasks of a project
  # TODO Refactor
  def timeslices
    t = Array.new
    tasks.each do |task|
      task.timeslices.each do |timeslice|
        t.push(timeslice)
      end
    end
    t
  end

  # Collection of stakeholders for select elements
  def stakeholders_for_select
      stakeholders.collect do |stakeholder|
      [stakeholder.user.full_name + " - " + stakeholder.role.humanize, stakeholder.user.id]
    end
  end

  # Total chargeable duration of timeslices for all tasks of a project
  def total_chargeable_duration
    tasks.collect(&:total_chargeable_duration).inject(0.0) { |sum, el| sum + el }
  end

  # Collection of stakeholders users who have emails enabled
  def recipients
    stakeholders.find_all {|s| s.user.receive_mail_from(self) }.collect {|s| s.user}
  end

  # Returns true if user is a stakeholder in the project
  def has_stakeholder?(user)
    users.include?(user)
  end

  # adds user as a stakeholder on the project with role
  def add_stakeholder(user, role = 'project_manager')
    stakeholders.create(:user => user, :role => role)
  end

  # By default, sort all finders by name
  def self.find(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    if not options.include? :order
      options[:order] = 'weight asc'
    end
    args.push(options)
    super
  end

  # Paginate
  def self.page(page)
    paginate :per_page => 50, :page => page, :order => 'name'
  end

  # Todo tasks
  def todo
    tasks.done
  end

  # Doing tasks
  def doing
    tasks.doing
  end

  # Done tasks
  def done
    tasks.done
  end

  # Include customer name
  def full_name
    "#{customer.name}: #{name}"
  end

  def activity_item
    {
      :user => self.user,
      :parent => self.customer,
      :subject => self,
      :action => ' created project ',
      :date => self.created_at,
      :object => self
    }
  end
end
