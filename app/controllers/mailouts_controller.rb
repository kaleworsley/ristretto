class MailoutsController < ApplicationController
  def index
    @mailout = Mailout.new
    @mailouts = Mailout.all
    @users = User.all :order => :last_name
  end

  def create
    @mailouts = Mailout.all
    @mailout = Mailout.new params[:mailout]
    @users = User.all :order => :last_name

    if params[:send_to_all_users]
      @mailout.users = User.all
    end

    if @mailout.save
      recipients = @mailout.deliver
      flash[:notice] = "Mailout sent to #{recipients.count} users"
      redirect_to mailouts_url
    else
      render 'index'
    end
  end
end
