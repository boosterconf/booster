require 'test_helper'

class TalkTest < ActiveSupport::TestCase
  context "talk" do
    should "increment comments count when adding a comment" do
      talk = talks(:one)
      comments_count = talk.comments_count
      talk.comments << Comment.new(:title =>"en tittel", :description => "en beskrivelse", :user => User.last)
      talk = Talk.find(talk.id)
      assert_equal comments_count + 1, talk.comments_count
    end

    should "increment participants count when adding a participant" do
      talk = Talk.first
      participant_count = talk.participants_count
      talk.participants << Participant.new(:user => User.last)
      talk = Talk.find(talk.id)
      assert_equal participant_count + 1, talk.participants_count
    end

    should "be pending by default" do
      talk = Talk.new
      assert talk.pending?
    end

    should "be accepted" do
      talk = Talk.new
      talk.accept!
      assert talk.accepted?
      assert !talk.refused?
      assert !talk.pending?
    end

    should "be refused" do
      talk = Talk.new
      talk.refuse!
      assert talk.refused?
      assert !talk.accepted?
      assert !talk.pending?
    end

    should "be able to regret" do
      talk = Talk.new
      talk.regret!
      assert talk.pending?
      assert !talk.refused?
      assert !talk.accepted?
    end

    should "not list refused talks" do
      refused = talks(:one).refuse!
      talks(:two).accept!
      not_refused = Talk.all_pending_and_approved
      assert !not_refused.include?(refused)
      assert not_refused.size > 0
    end

    should "not be full if current number of participants are less than maximum number of participants" do
      talk = talks(:not_full_tutorial)
      assert !talk.is_full?
    end

    should "be full if current number of participants are equal to maximum number of participants" do
      talk = talks(:full_tutorial)
      assert talk.is_full?
    end

    should "not be in supplied periods if supplied periods are empty" do
      talk = talks(:two)
      periods = []
      assert !talk.is_in_one_of_these(periods)
    end

    should "be in supplied periods if supplied periods contains one of the talk's periods" do
      talk = talks(:spans_several_slots)
      periods = (Array.new << talk.periods.first)
      assert talk.is_in_one_of_these(periods)
    end


    should "have start time equal to the period's start time if talk belongs to a single period" do
      talk = talks(:ten)
      assert_equal talk.periods.first.start_time, talk.start_time
    end

    should "have start time equal to the first period's start time if talk belongs to several periods" do
      talk = talks(:spans_several_slots)
      assert_equal periods(:one).start_time, talk.start_time
    end

  end

end