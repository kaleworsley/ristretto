class UserSessionsController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create]

  def new
    unless params[:redirect].blank?
      @redirect = params[:redirect]
    else
      @redirect = root_url
    end
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = 'Logged in.'
      redirect_to params[:redirect] || root_url
    else
      render :action => 'new'
    end
  end

  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    flash[:notice] = 'Successfully logged out.'
    unless params[:redirect].blank?
      redirect_to params[:redirect]
    else
      redirect_to root_url
    end
  end
end
