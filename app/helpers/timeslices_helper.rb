module TimeslicesHelper
  def mcdropdown_ul(user)
    out = '<ul id="task_mc_dropdown" class="mcdropdown_menu">'
    user.current_customers.each do |customer|
      out += '<li rel="c' + customer.id.to_s + '">'
      out += customer.name
      if customer.projects.present?
        out += '<ul>'
        customer.projects.each do |project|
          out += '<li rel="p' + project.id.to_s + '">'
          out += project.name
          if project.tasks.present?
            out += '<ul>'
            project.tasks.each do |task|
              out += '<li rel="' + task.id.to_s + '">'
              out += task.name
              out += '</li>'
            end
            out += '</ul>'
          end
          out += '</li>'
        end
        out += '</ul>'
      end
      out += '</li>'
    end
    out += '</ul>'
    out
  end
end