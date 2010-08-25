module TasksHelper
  def short_link_to_task(task)
    name = h(truncate(task.to_s, :length => 50))
    unless task.assigned_to.nil?
      name = "#{name} (<strong title=\"#{task.assigned_to}\">#{h(task.assigned_to.initials)}</strong>)"
    end
    link_to name, task, {:title => task}
  end
end
