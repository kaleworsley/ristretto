class Customer < ActiveRecord::Base
  searchable do
    text :name
  end

  # Create revisions
  versioned

  validates_presence_of :name
  validates_uniqueness_of :name
  has_many :projects, :dependent => :destroy

  def projects_tasks
    project_task = Struct.new(:name, :id)
    projects.map {|p| p.tasks.map {|t| project_task.new("#{p.name}: #{t.name}", t.id) }}.flatten
  end

  # By default, sort all finders by name
  def self.find(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options[:order] = 'name asc' unless options.include? :order
    args.push(options)
    super
  end

  def to_s
    name
  end

  def self.page(page)
    paginate :per_page => 50, :page => page, :order => 'name'
  end
end
