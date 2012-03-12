class UserPresenter < BasePresenter
  presents :user
  delegate :full_name, :email, :single_access_token, :to => :user

  def gravatar
    h.gravatar(user)
  end

end
