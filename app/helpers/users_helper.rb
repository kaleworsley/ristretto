module UsersHelper
  def gravatar(user, size = 80)
    url = 'http://www.gravatar.com/avatar/' +
      Digest::MD5.hexdigest(user.email.downcase)

    url = "#{url}?s=#{size}" unless size.nil?

    tag('img', { :class => 'gravatar', :width => size, :height => size,
                 :alt => user.full_name, :src => url + "&d=mm" })
  end

  def user_task_summary(user)
    if user.is_staff
      pluralize(user.assigned_tasks.doing.count, 'active task')
    else
      pluralize(user.tasks.delivered.count, 'task') + ' awaiting approval'
    end
  end
end
