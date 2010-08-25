module ProjectsHelper
  def short_link_to_project(project)
    name = h(truncate(project.to_s, :length => 50))
    link_to name, project, {:title => project}
  end
end