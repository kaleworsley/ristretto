require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  def setup
    @comment = Comment.new :body => 'Comment body', :user_id => users(:user1).id,
                           :task_id => tasks(:task1).id
  end

  test "should save a comment" do
    assert @comment.save, 'saved valid comment'
  end

  def test_should_save_without_body
    @comment.body = nil
    assert @comment.save, 'saved comment without body'
  end

  def test_should_not_save_without_user
    @comment.user = nil
    assert !@comment.save, 'saved comment without user'
  end

  def test_should_not_save_without_task
    @comment.task_id = nil
    assert !@comment.save, 'saved comment without task'
  end
end
