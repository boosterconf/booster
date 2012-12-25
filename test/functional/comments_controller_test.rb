require 'test_helper'

class CommentsControllerTest < ActionController::TestCase

  def setup
    login_as('quentin')
    @talk = talks(:one)
  end

  def test_should_create_comment
    talk_id = @talk.id
    assert_difference("Talk.find(#{talk_id}).comments_count", difference = 1) do
      assert_difference('Comment.count') do
        post :create, :comment => {:title => 'foo', :description => 'bar'}, :talk_id => talk_id
      end
    end
    assert_redirected_to talk_path(assigns(:talk))
  end

end
