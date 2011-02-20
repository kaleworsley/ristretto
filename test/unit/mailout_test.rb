require 'test_helper'

class MailoutTest < ActiveSupport::TestCase
  def setup
    @mailout = Factory.create(:mailout)
  end

  test "should not save without a subject" do
    @mailout.subject = ''
    assert !@mailout.save
  end

  test "should not save without a body" do
    @mailout.body = ''
    assert !@mailout.save
  end

  test "sent should default to false" do
    assert_equal false, Mailout.new.sent
  end

  test "should deliver mailout" do
    user1, user2 = Factory.create(:user), Factory.create(:user)
    @mailout.users = [user1, user2]
    assert_difference 'ActionMailer::Base.deliveries.count', 2 do
      # Send method should return an array of the recipients
      assert_equal [user1, user2], @mailout.deliver
    end
    assert @mailout.sent
  end
end
