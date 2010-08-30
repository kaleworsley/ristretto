class AddDefaultTaskState < ActiveRecord::Migration
  def self.up
    Task.find(:all, :order => :id).each {|t| t.state = 'not_started' if t.state.nil?}
    change_column :tasks, :state, :string, :default => 'not_started'
  end

  def self.down
    change_column :tasks, :state, :text
  end
end
