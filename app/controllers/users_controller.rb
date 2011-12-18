class UsersController < ApplicationController
  before_filter :find_user, :only => [:show, :delete, :edit, :update]

  # GET /users
  # GET /users.xml
  def index
    @users = User.page(params[:page])

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
    if @user.update_attributes(params[:user])
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
end
