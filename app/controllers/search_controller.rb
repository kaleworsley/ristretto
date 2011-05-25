class SearchController < ApplicationController

  def search
    # 403 if the user isn't logged in, or isn't a staff member
    if current_user.blank? || !current_user.is_staff?
      render_403
    end

    @q = query = params[:q] || params[:term]
    @page = page = (params[:page] ? params[:page].to_i : 1)

    @search = Sunspot.search Customer, Project, Task, Comment, Timeslice, User do
      keywords query
    	paginate :page => page
     end

    respond_to do |format|
      format.html do
        # Go to the first result if there is only one
        if @search.results.size == 1
          return redirect_to(@search.results.first)
        end
      end
      # FIXME: This needs to be nicer
      format.json { render :json => @search.results[0..10].map {|o| {:label => "#{ (o.to_s.size > 50) ? o.to_s.slice(0, 50) + '...' : o.to_s } - #{ o.class.to_s }", :value => o.to_s.split(' ')[0..30].join(' ') } } }
    end
  end
end

