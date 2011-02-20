class Mailer < ActionMailer::Base

  default_url_options[:host] = SETTINGS['host']

  def task_comment(comment, recipient)
    recipients  recipient.email
    from        SETTINGS['default_email']
    subject     "[#{SETTINGS['name']}] Task comment: " + comment.task.name
    body        :comment => comment, :user => recipient
  end

  def password_reset_instructions(user)
    subject       "[#{SETTINGS['name']}] Password reset instructions"
    from          SETTINGS['default_email']
    recipients    user.email
    body          :reset_password_url => reset_password_url(user.perishable_token)
  end

  def mailout(mailout, user)
    subject       mailout.subject
    from          SETTINGS['default_email']
    recipients    user.email
    body          :mailout => mailout, :user => user
  end
end
