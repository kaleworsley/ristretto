class Timeslice < ActiveRecord::Base
  searchable do
    text :description
  end
  # Create revisions
  versioned

  validates_presence_of :started, :finished
  validates_presence_of :user_id
  validate :finished_must_be_after_started, :if => :started_and_finished_set?
  validate :must_not_overlap, :if => :started_and_finished_set?

  belongs_to :task
  belongs_to :user

  named_scope :by_date, lambda { |start_date,*end_date|
    {
      :conditions => [ 'started >= ? AND finished < ?',
      start_date.to_time.utc,
      end_date.first ? end_date.first.tomorrow.to_time.utc : start_date.tomorrow.to_time.utc ]
    }
  }

  named_scope :by_task_ids, lambda { |task_ids|
    {
      :conditions => { :task_id => task_ids }
    }
  }

  named_scope :uninvoiced, :conditions => ['(timeslices.ar IS NULL) OR (timeslices.ar = 0)'], :include => [:task => { :project => :customer }]
  named_scope :recent_invoices, lambda { |user|
    if user.is_staff
      {
        :include => { :task => :project },
        :group => :ar,
        :limit => 10,
        :order => 'timeslices.ar DESC'
      }
    else
      {
        :conditions => {
          :task_id => user.current_projects_tasks_ids
        },
        :include => {
          :task => :project
        },
        :group => :ar,
        :limit => 10,
        :order => 'timeslices.ar DESC'
      }
    end
  }

  def to_s
    description
  end

  # Paginate
  def self.page(page)
    paginate :per_page => 50, :page => page
  end

  # By default, sort all finders by start time
  def self.find(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    if not options.include? :order
      options[:order] = 'started asc'
    end
    args.push(options)
    super
  end

  # Timeslice day name e.g. Thursday
  def day_name
    self.started.strftime('%A')
  end

  # Timeslice day name e.g. 1 (Monday)
  def day_number
    self.started.strftime('%w')
  end

  # Timeslice week e.g. 2010-32
  def week
    self.started.strftime('%Y-%W')
  end

  # Timeslice week e.g. 2010
  def year
    self.started.strftime('%Y')
  end

  # Timeslice week e.g. 2010-11
  def month
    self.started.strftime('%Y-%b')
  end

  # Timeslice week e.g. 2010-11-14
  def date
    self.started.strftime('%Y-%b-%d')
  end

  # Returns a sum of the total duration of an array of timeslices
  def Timeslice.total_duration(timeslices)
    timeslices.inject(0) {|total,timeslice| total += timeslice.duration}
  end

  # Returns a sum of the total chargeable duration of an array of timeslices
  def Timeslice.total_chargeable_duration(timeslices)
    timeslices.find_all {|timeslice| timeslice.chargeable}.inject(0) {|total,timeslice| total += timeslice.duration}
  end

  # Returns a sum of the total nonchargeable duration of an array of timeslices
  def Timeslice.total_nonchargeable_duration(timeslices)
    Timeslice.total_duration(timeslices) - Timeslice.total_chargeable_duration(timeslices)
  end

  # Duration in seconds
  def duration
    finished - started
  end

  # Duration in hours
  def duration_in_hours
    (duration/60/60).round(2)
  end

  # Start time of a timeslice e.g. 13:54
  def started_time
    self.started.to_s(:time_only)
  end

  # Set the start time of a timeslice e.g. 13:54
  def started_time=(started_time)
    self.started = Time.parse(started_time)
  rescue ArgumentError
    @started_time_invalid = true
  end

  # Finish time of a timeslice e.g. 13:54
  def finished_time
    self.finished.to_s(:time_only)
  end

  # Set the finished time of a timeslice e.g. 13:54
  def finished_time=(finished_time)
    self.finished = Time.parse(finished_time)
  rescue ArgumentError
    @finished_time_invalid = true
  end

  # Date of a timeslice
  def date
    started.to_date
  end

  # Set the date of a timeslice
  def date=(date)
    self.started = Time.parse("#{date} #{self.started.strftime('%H:%M:%S')}")
    self.finished = Time.parse("#{date} #{self.finished.strftime('%H:%M:%S')}")
  end

  # Check for a stakeholder
  def has_stakeholder?(user)
    task.has_stakeholder?(user)
  end

  # Returns the previous timeslice (for the same user)
  def previous
    Timeslice.find(:first,
      :conditions => ["finished <= ? AND user_id = ?", started, user_id],
      :order => 'finished DESC')
  end

  # Returns the next timeslice (for the same user)
  def next
    Timeslice.find(:first,
      :conditions => ["started >= ? AND user_id = ?", finished, user_id],
      :order => 'finished ASC')
  end

  # Compares the timeslice passed with this timeslice to see if they
  # are on the same day.
  def same_day_as?(timeslice)
    return self.date == timeslice.date
  end

  def activity_item
    {
      :user => self.user,
      :parent =>   self.task.project,
      :subject => self.task,
      :action => ' spent ' + distance_of_time_in_words(self.started, self.finished) + ' on ',
      :date => self.started,
      :object => self
    }
  end

  private
    def started_and_finished_set?
      started && finished && !user_id.nil?
    end

    def finished_must_be_after_started
      if started >= finished
        errors.add(:finished, "must be after started time")
      end
    end

    def validate
      errors.add(:started_time, "is invalid") if @started_time_invalid
      errors.add(:finished_time, "is invalid") if @finished_time_invalid
    end

    def must_not_overlap
      conditions = '(started < :started AND finished > :started) OR
                    (started < :finished AND finished > :finished) OR
                    (started = :started AND finished = :finished) OR
                    (started > :started AND finished < :finished)'
      options = { :started => self.started, :finished => self.finished }

      # If this is not a new record, exclude self.id from the search
      unless self.new_record?
        conditions = '(' + conditions + ')' + ' AND (id != :id)'
        options.merge!(:id => self.id)
      end

      if self.user.timeslices.first(:conditions => [conditions, options])
        errors.add(:started, "overlaps with another timeslice")
      end
    end
end

