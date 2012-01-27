class Comment < ActiveRecord::Base
  has_many :attachments, :as => :attachable, :dependent => :destroy, :class_name => '::Attachment'
  belongs_to :task
end

class MigrateAttachmentsToProjects < ActiveRecord::Migration
  def self.up
    Attachment.all(:conditions => ['attachable_type <> "Project"']).each do |a|
      if a.attachable_type == "Comment"
        if a.attachable.task
          a.update_attributes(:attachable_type => "Project", :attachable_id => a.attachable.task.project_id)
        else 
          puts "Attachable for #{a.id} not found!"
        end
      elsif a.attachable_type == "Task"
        if a.attachable
          a.update_attributes(:attachable_type => "Project", :attachable_id => a.attachable.project_id)
        else 
          puts "Attachable for #{a.id} not found!"
        end
      end      
    end
  end

  def self.down
  end
end
