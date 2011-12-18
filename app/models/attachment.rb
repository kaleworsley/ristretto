class Attachment < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true
  belongs_to :user
  has_attached_file :file, :url => "/attachments/:id/download",
                           :path => ":rails_root/public/system/:attachment/:id/:style/:basename.:extension"

  validates_attachment_presence :file

  def attachment_for name
    @_paperclip_attachments ||= {}
    @_paperclip_attachments[name] ||= Attachment.new(name, self, self.class.attachment_definitions[name])
  end

  def to_s
    file_file_name
  end

  def self.page(page)
    paginate :per_page => 50, :page => page
  end

  def activity_item
    {
      :user => self.user,
      :parent => self.attachable,
      :subject => self,
      :action => ' uploaded ',
      :date => self.created_at,
      :object => self
    }
  end
end
