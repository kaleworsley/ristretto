class UsersController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create]
  before_filter :find_user, :only => [:show, :delete, :edit, :update]
  load_and_authorize_resource

  # GET /users
  # GET /users.xml
  def index
    if current_user.is_staff?
      @users = User.page(params[:page])
    else
      @users = User.paginate(:per_page => 50, :page => params[:page], :conditions => {:id => current_user.users.collect(&:id)})
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end


  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.reset_single_access_token
    if @user.save
      flash[:notice] = 'User created'
      redirect_to root_path
    else
      render :action => 'new'
    end
  end

  def edit

  end

  def update
    if @user.update_attributes(params[:user]) && update_is_staff
      if params[:reset_api_key] == "1"
        @user.reset_single_access_token
        @user.save
      end
      flash[:notice] = 'Profile updated'
      redirect_to user_url(@user)
    else
      render :action => 'edit'
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  private

    def find_user
      if params[:id].blank?
        @user = current_user
      else
        @user = User.find(params[:id])
      end
    end

    def update_is_staff
      # The is_staff attribute is protected.  Return immeadiately if the
      # user doesn't have permissions to update
      return true unless current_user.is_staff

      # Nothing to do if the old and new values are the same
      return true if @user.is_staff == params[:user][:is_staff]

      @user.is_staff = params[:user][:is_staff]
      @user.save
    end
end
