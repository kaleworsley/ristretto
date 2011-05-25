class SearchController < ApplicationController
  
  def search
    # 403 if the user isn't logged in, or isn't a staff member
    if current_user.blank? || !current_user.is_staff?
      render_403
    end
    
    @q = query = params[:q]
    @page = page = (params[:page] ? params[:page].to_i : 1)
    @search = Sunspot.search Customer, Project, Task, Comment, Timeslice, User do 
      keywords query
    	paginate :page => page
    end
    
    # Go to the first result if there is only one
    if @search.results.size == 1
      return redirect_to(@search.results.first)
    end
  end
end


