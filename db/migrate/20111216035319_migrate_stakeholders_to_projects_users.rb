class MigrateStakeholdersToProjectsUsers < ActiveRecord::Migration
  def self.up
    Project.all.each do |p|
      p.user_ids= p.stakeholders.map(&:user_id)
      p.save
    end
  end

  def self.down
    Project.all.each do |p|
      p.user_ids.each do |user_id|
        Stakeholder.create(:project_id => p.id, :user_id => user_id, :role => 'developer')
      end
    end
  end
end
