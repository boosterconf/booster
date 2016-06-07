require 'test_helper'

class TalkTest < ActiveSupport::TestCase

  should 'increment comments count when adding a comment' do
    talk = talks(:one)
    comments_count = talk.comments_count
    talk.comments << Comment.new(:title => 'en tittel', :description => 'en beskrivelse', :user => User.last)
    talk = Talk.find(talk.id)
    assert_equal comments_count + 1, talk.comments_count
  end

  should 'not list refused talks' do
    refused = talks(:one).refuse!
    talks(:two).accept!
    not_refused = Talk.all_pending_and_approved

    refute not_refused.include?(refused)
  end

  context 'changing acceptance statuses' do

    setup do
      @talk = Talk.new
    end

    should 'be pending by default' do
      assert @talk.pending?
    end

    should 'be accepted' do
      @talk.accept!

      assert @talk.accepted?
      refute @talk.refused?
      refute @talk.pending?
    end

    should 'be refused' do
      @talk.refuse!

      assert @talk.refused?
      refute @talk.accepted?
      refute @talk.pending?
    end

    should 'be able to regret' do
      @talk.regret!
      assert @talk.pending?
      refute @talk.refused?
      refute @talk.accepted?
    end
  end

  context '#is_presented_by' do

    should 'be true when user is amongst talk\'s speakers ' do
      talk = talks(:three)

      assert talk.is_presented_by?(talk.users.first)

    end

    should 'be false when user is not amongst talk\'s speakers ' do
      talk = talks(:three)

      refute talk.is_presented_by?(users(:god))

    end
  end

end