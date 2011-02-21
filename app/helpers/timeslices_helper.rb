module TimeslicesHelper
  def mcdropdown_ul(user)
    out = '<ul id="task_mc_dropdown" class="mcdropdown_menu">'
    user.current_customers.sort_by(&:name).each do |customer|
      projects = customer.projects.selectable
      if projects.present? && projects.collect {|p| p.tasks.selectable.size }.inject {|sum,x| sum ? sum + x : x } > 0
        out += '<li rel="c' + customer.id.to_s + '">'
        out += customer.name
        out += '<ul>'
        projects.each do |project|
          tasks = project.tasks.selectable
          if tasks.present?
            out += '<li rel="p' + project.id.to_s + '">'
            out += project.name
            out += '<ul>'
            tasks.each do |task|
              out += '<li rel="' + task.id.to_s + '">' + task.name + '</li>'
            end
            out += '</ul>'
            out += '</li>'
          end
        end
        out += '</ul>'
        out += '</li>'
      end
    end
    out += '</ul>'
    out
  end
end
