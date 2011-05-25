# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'cgi'

class ApplicationController < ActionController::Base
  include ExceptionNotification::Notifiable
  helper :all # include all helpers, all the time
  helper_method :current_user

  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include ActionView::Helpers::TextHelper
  end



  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '6da3025a7e4f60850092308845074226'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  filter_parameter_logging :password


  before_filter :require_login
  before_filter :unsaved_timeslices

  # By default throw 404 for all record not found
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  # By default throw 403 for all authorization errors
  rescue_from CanCan::AccessDenied, :with => :render_403

  # Before filter to check for user login in any controller
  def require_login
    unless current_user
      store_location
      respond_to do |format|
        format.html do
          flash[:warning] = 'You must be logged in to view this page'
          redirect_to login_path
        end
        format.xml do
          render :nothing => true, :status => :forbidden
        end
      end
      return false
    end
  end

  # Before filter to check that the user isn't logged it
  def require_no_login
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to root_path
      return false
    end
  end

  # 404 Page
  def show_404
    render_404
  end

  # 403 Page
  def show_403
    render_403
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  # Extract timeslice data from the cookies array
  # FIXME: This is nasty.
  def unsaved_timeslices
    if @current_user && @current_user.is_staff?
      @timeslice_timers = []
      @timeslice_started = {}
      @timeslice_finished = {}
      @timeslice_description = {}
      @unsaved_timeslices = {}
      cookies.each do |name, value|
        split = CGI.unescape(name).to_s.split(':')
        if name.index('timeslice') == 0 && split[1] != nil
          if @unsaved_timeslices[split[1].to_i].nil?
            @unsaved_timeslices[split[1].to_i] = Task.find(split[1].to_i)
          end
        end
        case (split[0])
          when 'timesliceTimer'
            @timeslice_timers.push(Task.find(split[1].to_i))
          when 'timesliceStarted'
            @timeslice_started[split[1].to_i] = value
          when 'timesliceFinished'
            @timeslice_finished[split[1].to_i] = value
          when 'timesliceDescription'
            @timeslice_description[split[1].to_i] = value
          else
        end
      end
    end
  end

  protected
  def render_404
    respond_to do |format|
      format.html do
        render :template => 'layouts/error_404', :status => :not_found
      end
      format.xml do
        render :nothing => true, :status => :not_found
      end
    end
  end

  def render_403
    respond_to do |format|
      format.html do
        render :template => 'layouts/error_403', :status => :forbidden
      end
      format.xml do
        render :nothing => true, :status => :forbidden
      end
    end
  end

  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    @current_user = current_user_session && current_user_session.record
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, request)
  end

end
