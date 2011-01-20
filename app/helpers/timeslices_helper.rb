module TimeslicesHelper
  def mcdropdown_ul(user)
    out = '<ul id="task_mc_dropdown" class="mcdropdown_menu">'
    user.current_customers.sort_by(&:name).each do |customer|
      out += '<li rel="c' + customer.id.to_s + '">'
      out += customer.name
      if customer.projects.find(:all, :conditions => {:state => ['proposed', 'current']}, :order => :name).present?
        out += '<ul>'
        customer.projects.find(:all, :conditions => {:state => ['proposed', 'current']}, :order => :name).each do |project|
          out += '<li rel="p' + project.id.to_s + '">'
          out += project.name
          if project.tasks.find(:all, :conditions => {:state => Task.stategroups[:current]}, :order => :name).present?
            out += '<ul>'
            project.tasks.find(:all, :conditions => {:state => Task.stategroups[:current]}, :order => :name).each do |task|
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
