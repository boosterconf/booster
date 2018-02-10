require 'test_helper'

class ReviewsControllerTest < ActionController::TestCase

  setup do
    @review = reviews(:one)
  end

  context 'A normal user' do
    setup do
      login_as(:quentin)
    end

    should 'not be able to access index' do
      get :index
      assert_response :redirect
    end

    should 'not be able to create reviews' do
      get :create
      assert_response :redirect
    end
  end

  context 'An Admin' do

    setup do
      login_as(:god)
    end

    should 'be able to access index' do
      get :index
      assert_response :success
    end

    should 'be able to create a review' do
      assert_difference('Review.count') do
        post :create, review: valid_review_params, talk_id: talks(:one).id, format: :js
      end

      assert_response :success
    end

    should 'be able to should update a review' do
      put :update, id: @review, review: valid_review_params, talk_id: talks(:one).id
      assert_redirected_to review_path(assigns(:review))
    end

    should 'be able to delete a review' do
      assert_difference('Review.count', -1) do
        delete :destroy, id: @review
      end

      assert_redirected_to reviews_path
    end
  end

  context '#create' do

    setup do
      login_as(:god)
    end

    should 'send notification' do
      ReviewNotifier.any_instance.expects(:notify_create)

      post :create, review: valid_review_params, talk_id: talks(:one).id, format: :js
    end

  end

  def valid_review_params
    { subject: 'More stuff!', text: "This needs more stuff" }
  end
end
