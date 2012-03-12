class Task < ActiveRecord::Base
  searchable do
    text :name
  end

  validates_presence_of :name
  validates_numericality_of :estimate, :greater_than => 0, :allow_nil => true

  belongs_to :project
  has_many :timeslices, :as => :timetrackable, :dependent => :destroy

  #NOTE: ":class_name => '::Attachment''" is required. There is a bug in paperclip
  #see: http://thewebfellas.com/blog/2008/11/2/goodbye-attachment_fu-hello-paperclip#comment-2415
  has_many :attachments, :as => :attachable, :dependent => :destroy, :class_name => '::Attachment'

  delegate :customer, :to => :project

  # Task states
  STATES = ['not_started','started','delivered','accepted','rejected',
            'duplicate','change_of_scope']
            
  STAGES = ['analysis', 'concepts', 'development', 'delivery', 'review']

  # Task state groups
  STATEGROUPS = {
    :current => ['not_started', 'rejected', 'started', 'delivered'],
    :todo    => ['not_started', 'rejected'],
    :doing   => ['started', 'delivered'],
    :done    => ['accepted', 'change_of_scope', 'duplicate'],
  }

  STATES.each do |state|
    named_scope state, :conditions => { :state => state }
  end

  STATEGROUPS.each do |stategroup,states|
    named_scope stategroup, :conditions => { :state => states }
  end

  TAGS = ["bug", "content", "database", "feature", "markup", "permissions", "scope creep", "style", "system"]

  named_scope :selectable, :conditions => {:state => STATEGROUPS[:current]}, :order => 'name asc'

  def timetrackable_object
    "Task|#{id}"
  end

  # Return a hash of available task states suitable for the select helper
  def Task.states_for_select
    STATES.collect { |state| [state.humanize, state] }
  end

  # Return a hash of available task stages suitable for the select helper
  def Task.stages_for_select
    STAGES.collect { |stage| [stage.humanize, stage] }
  end

  # Task states
  def Task.states
    STATES
  end

  # Task state groups
  def Task.stategroups
    STATEGROUPS
  end

  # Paginate
  def self.page(page)
    paginate :per_page => 50, :page => page, :order => 'name'
  end

  def to_s
    name
  end

  # By default, sort all finders by order
  def self.find(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    if not options.include? :order
      options[:order] = 'tasks.weight ASC'
    end
    args.push(options)
    super
  end

  # Duration of all timeslices for a task
  def duration(date = nil)
    duration = 0
    if date.nil?
      slices = timeslices.each
    else
      slices = timeslices.by_date(date).each
    end
    slices.each do |timeslice|
      duration += timeslice.duration
    end
    duration
  end

  # Total chargeable duration of timeslices for a task
  def total_chargeable_duration
    duration = 0
    timeslices.each do |timeslice|
      duration += timeslice.duration unless !timeslice.chargeable
    end
    duration
  end
  
  def total_chargeable_duration_hours
    total_chargeable_duration/60/60
  end

  # Total nonchargeable duration of timeslices for a task
  def total_nonchargeable_duration
    duration - total_chargeable_duration
  end


  def uninvoiced
    timeslices.select do |timeslice|
      !timeslice.chargeable || timeslice.invoice.blank?
    end
  end

  def total_chargeable_uninvoiced_duration
    duration = 0
    uninvoiced.each do |timeslice|
      duration += timeslice.duration
    end
    duration
  end
  
  def total_chargeable_uninvoiced_duration_hours
    total_chargeable_uninvoiced_duration/60/60
  end

  def to_option
    ["#{project.customer.name} - #{project.name} : #{name}", timetrackable_object]
  end

  # Include customer and project names
  def full_name
    "#{project.full_name}: #{name}"
  end

  def mine?(user)
    assigned_to == user
  end

  def extract_tags
    name.scan(/(^#\w+|\s#\w+)/).collect {|tag| tag[0].strip.gsub(/\#/,'').underscore.humanize.titleize}
  end

  def has_tag?(tag)
    extract_tags.include? tag.titleize
  end

  def tag_classes
    TAGS.find_all {|tag| has_tag? tag}.collect(&:parameterize).join(' ')
  end

  # Returns an array of expected state progressions for this task.  For
  # example, a task in state 'not_started' is expected to progress to
  # 'started'.  A task in state 'delivered' is expected to progress to
  # 'accepted or 'rejected'
  def next_states
    case state
    when "not_started": ["started"]
    when "started": ["delivered"]
    when "delivered": ["accepted","rejected"]
    when "rejected": ["started"]
    else
      []
    end
  end


  def activity_item
    {
      :user => self.user,
      :parent => self.project,
      :subject => self,
      :action => ' created task ',
      :date => self.created_at,
      :object => self
    }
  end
end
