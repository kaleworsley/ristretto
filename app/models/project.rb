class Project < ActiveRecord::Base
  searchable do
    text :name
  end

  validates_presence_of :name
  validates_presence_of :customer_id
  validates_numericality_of :estimate, :greater_than => 0, :allow_nil => true

  belongs_to :customer
  has_many :tasks, :dependent => :destroy
  has_many :tickets, :as => :ticketable
  has_and_belongs_to_many :users, :uniq => true
  
  delegate :todo, :to => :tasks
  delegate :doing, :to => :tasks
  delegate :done, :to => :tasks


  accepts_nested_attributes_for :tasks, :reject_if => Proc.new {|t| t['name'].blank?}, :allow_destroy => true
 
  #NOTE: ":class_name => '::Attachment''" is required. There is a bug in paperclip
  #see: http://thewebfellas.com/blog/2008/11/2/goodbye-attachment_fu-hello-paperclip#comment-2415
  has_many :attachments, :as => :attachable, :dependent => :destroy, :class_name => '::Attachment'

  # Project states
  STATES = ['proposed', 'current', 'postponed', 'complete']

  # Project kinds
  KINDS = ['development', 'support']

  STATES.each do |state|
    named_scope state, :conditions => { :state => state }, :include => [{:tasks => :timeslices}, :customer], :order => 'name asc'
  end

  # The overrunning? method will only test the project status if the percentage
  # of budget used is greater than this value
  OVERRUN_THRESHOLD = 50

  KINDS.each do |kind|
    named_scope kind, :conditions => { :kind => kind }
  end

  named_scope :selectable, :conditions => {:state => ['proposed', 'current']}, :order => 'name asc'

  # Return a hash of available project states suitable for the select helper
  def Project.states_for_select
    STATES.collect { |state| [state.humanize, state] }
  end

  # Return a hash of available project kinds suitable for the select helper
  def Project.kinds_for_select
    KINDS.collect { |kind| [kind.humanize, kind] }
  end

  def ticketable_object
    "Project|#{id}"
  end

  def to_option
    ["#{customer.name} - #{name}", ticketable_object]
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

  # Total chargeable duration of timeslices for all tasks of a project in seconds
  def total_chargeable_duration
    tasks.collect(&:total_chargeable_duration).inject(0.0) { |sum, el| sum + el }
  end

  # Total chargeable hours spent on the project so far, rounded to 2 decimal
  # places
  def total_chargeable_hours
    (total_chargeable_duration / 1.hour).round(2)
  end

  # By default, sort all finders by name
  def self.find(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    if not options.include? :order
      options[:order] = 'name asc'
    end
    args.push(options)
    super
  end

  # Paginate
  def self.page(page, conditions = {})
    paginate :per_page => 50, :page => page, :order => 'name', :conditions => conditions
  end

  # Include customer name
  def full_name
    "#{customer.name}: #{name}"
  end

  # Returns the percentage of budget used.
  def percentage_of_budget_used
    if estimate.present?
      total_chargeable_hours / (estimate / 100)
    end
  end

  # Returns the percentage of total tasks which have been completed for this
  # project
  def percentage_complete
    if tasks.count > 0
      tasks.done.count / (tasks.count.to_f / 100)
    else
      0
    end
  end

  # Returns true if the project is overrunning.  Always returns false if used
  # budget is below OVERRUN_THRESHOLD
  def overrunning?
    return false if percentage_of_budget_used.nil? || percentage_of_budget_used < OVERRUN_THRESHOLD
    percentage_of_budget_used > percentage_complete
  end
end
