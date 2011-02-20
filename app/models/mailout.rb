class Mailout < ActiveRecord::Base
  has_and_belongs_to_many :users
  validates_presence_of :subject, :body

  # Delivers the mailout to it's list of users.  Returns the list of users
  # to whom the message was delivered.
  def deliver
    recipients = users.select do |user|
      Mailer.deliver_mailout(self, user)
    end
    self.update_attributes!(:sent => true)
    recipients
  end
end
