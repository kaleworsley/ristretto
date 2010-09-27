class Stakeholder < ActiveRecord::Base
  # Create revisions
  versioned

  validates_presence_of :user_id
  validates_presence_of :project_id

  belongs_to :user
  belongs_to :project

  attr_reader :stakeholder_roles

  # Stakeholder roles
  ROLES = ['project_manager', 'customer_representative', 'developer', 'designer',
           'support', 'accounts', 'scrum_master']

  ROLES.each do |role|
    named_scope role, lambda { |user|
      if user.present?
        { :conditions => { :role => role, :user_id => user.id } }
      else
        { :conditions => { :role => role } }
      end
    }
  end

  # Return a hash of available stakeholder roles suitable for the select helper
  def Stakeholder.roles_for_select
    ROLES.collect { |role| [role.humanize, role] }
  end

  def to_s
    project + " - " + user
  end


  def activity_item
    {
      :user => self.user,
      :parent => self.project.customer,
      :subject => self.project,
      :action => ' was added to project ',
      :date => self.created_at,
      :object => self
    }
  end
end
