class DashboardController < ApplicationController
  def index
    respond_to do |format|
      format.html
    end
  end

  def widget
    respond_to do |format|
      format.html { render :partial => 'widget' }
    end
  end
end
