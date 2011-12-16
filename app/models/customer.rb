class Customer < ActiveRecord::Base
  searchable do
    text :name
  end

  # Create revisions
  versioned

  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :projects, :dependent => :destroy

  # Collection of all the stakeholders (User) of all the projects that belong to
  # a customer
  def users(reset = false)
    projects.each.collect { |project| project.users(reset) }.flatten.uniq
  end

  def projects_tasks
    project_task = Struct.new(:name, :id)
    
    projects.map {|p| p.tasks.map {|t| project_task.new("#{p.name}: #{t.name}", t.id) }}.flatten
  end
  

  # Check for a stakeholder
  def has_stakeholder?(user)
    users.include?(user)
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

  def to_s
    name
  end

  def self.page(page)
    paginate :per_page => 50, :page => page, :order => 'name'
  end

  def activity_item
    {
      :user => self.user,
      :parent => self,
      :subject => self,
      :action => ' created customer ',
      :date => self.created_at,
      :object => self
    }
  end
end
