class Comment < ActiveRecord::Base
  # Create revisions
  versioned

  validates_presence_of :user_id, :task_id
  belongs_to :user
  belongs_to :task

  # NOTE: ":class_name => '::Attachment''" is required. There is a bug in paperclip
  # see: http://thewebfellas.com/blog/2008/11/2/goodbye-attachment_fu-hello-paperclip#comment-2415
  has_many :attachments, :as => :attachable, :dependent => :destroy, :class_name => '::Attachment'

  # Check the comment's task's project for a stakeholder
  def has_stakeholder?(user)
    task.has_stakeholder?(user)
  end

  def deliver_notifications
    task.recipients.reject {|u| u == user}.each do |recipient|
      Mailer.deliver_task_comment(self, recipient)
    end
  end
end
