class Stakeholder < ActiveRecord::Base
  
end


class ChangeTaskStatesAndStakeholderRoles < ActiveRecord::Migration
  def self.up
    tasks = Task.find(:all, :order => :id)
    tasks.each do |task|
      task.state.gsub!('-', '_')
      task.save
   end
    stakeholders = Stakeholder.find(:all, :order => :id)
    stakeholders.each do |stakeholder|
      stakeholder.role.gsub!('-', '_')
      stakeholder.save
    end
  end
  
  def self.down
    tasks = Task.find(:all, :order => :id)
    tasks.each do |task|
      task.state.gsub!('_', '-')
      task.save
    end
    stakeholders = Stakeholder.find(:all, :order => :id)
    stakeholders.each do |stakeholder|
      stakeholder.role.gsub!('_', '-')
      stakeholder.save
    end
  end
end
