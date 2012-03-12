class SearchController < ApplicationController

  def search
    # 403 if the user isn't logged in
    if current_user.blank?
      render_403
    end

    @q = query = params[:q] || params[:term]
    @page = page = (params[:page] ? params[:page].to_i : 1)

    @search = Sunspot.search Customer, Project, Task, Timeslice, User do
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
     format.json do
       @json = @search.results.map do |o|
         {:label => o.to_s, :value => o.to_s }
       end
       render :json => @json
     end
    end
  end
end

