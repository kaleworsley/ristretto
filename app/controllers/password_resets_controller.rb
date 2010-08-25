class PasswordResetsController < ApplicationController
  skip_before_filter :require_login
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :require_no_login

  def new

  end

  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = "Instructions to reset your password have been emailed to you. " +
        "Please check your email."
      redirect_to login_url
    else
      flash[:warning] = "No user was found with that email address"
      redirect_to reset_url
    end
  end


  def edit

  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      UserSession.create(@user)
      flash[:notice] = "Password successfully updated"
      redirect_to root_url
    else
      render :action => :edit
    end
  end

  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:notice] = "We're sorry, but we could not locate your account. " +
        "If you are having issues try copying and pasting the URL " +
        "from your email into your browser or restarting the " +
        "reset password process."
      redirect_to login_url
    end
  end
end
