require 'test_helper'

class MailoutsControllerTest < ActionController::TestCase

  def setup
    @user = Factory.create(:user)
    @staff = Factory.create(:staff)
    @mailout = Factory.create(:mailout)
    @mailout_params = Factory.attributes_for(:mailout)
    activate_authlogic
  end

  test "should not get index if not staff" do
    UserSession.create(@user)
    get :index
    assert_response :forbidden
  end

  test "should get index if staff" do
    UserSession.create(@staff)
    get :index
    assert_response :success
    assert assigns(:mailouts)
    assert assigns(:mailout)
  end

  test "should not create if not staff" do
    UserSession.create(@user)
    assert_no_difference 'Mailout.count' do
      post :create, :mailout => @mailout_params
    end
    assert_response :forbidden
  end

  test "should create a mailout for all users" do
    UserSession.create @staff
    assert_mailout_sent_to User.all do
      post :create, :mailout => @mailout_params, :send_to_all_users => true
    end
    assert_redirected_to mailouts_url
  end

  test "should create a mailout for specific users" do
    UserSession.create @staff
    user2 = Factory.create(:user)
    mailout_recipients = [@user, user2]
    @mailout_params[:user_ids] = mailout_recipients.map(&:id)
    assert_mailout_sent_to mailout_recipients do
      post :create, :mailout => @mailout_params
    end
  end

  private

  # Yields the given block and checks that a mail was sent to each user in
  # users, and that a single mailout was created.
  def assert_mailout_sent_to(users)
    assert_difference 'Mailout.count', 1 do
      assert_difference 'ActionMailer::Base.deliveries.count', users.count do
        yield
      end
    end
  end
end
