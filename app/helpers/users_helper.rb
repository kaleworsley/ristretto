module UsersHelper
  def gravatar(user, size = 80)
    url = 'http://www.gravatar.com/avatar/' +
      Digest::MD5.hexdigest(user.email.downcase)

    url = "#{url}?s=#{size}" unless size.nil?

    tag('img', { :class => 'gravatar', :width => size, :height => size,
                 :alt => user.full_name, :src => url + "&d=mm" })
  end

  def user_task_summary(user)
    pluralize(user.assigned_tasks.doing.count, 'active task')
  end
end
