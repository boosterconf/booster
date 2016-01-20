require 'test_helper'

class SpeakerNameTest < ActiveSupport::TestCase

  context '#speaker_name' do

    context 'with one speaker only' do
      setup do
        @users = [users(:god)]
      end

      should 'be only the speaker name' do
        assert_equal SpeakerName.new(@users).to_s, @users.first.full_name
      end
    end

    context 'with two named speakers' do
      setup do
        @users = [users(:god), users(:quentin)]
      end

      should 'be both the speakers full names separated by \"and\"' do
        speaker_name = SpeakerName.new(@users).to_s
        assert (speaker_name == "#{@users.first.full_name} and #{@users.last.full_name}") ||
                (speaker_name == "#{@users.last.full_name} and #{@users.first.full_name}")
      end
    end

    context 'with one named and one unnamed speaker' do
      setup do
        @users = [User.new, users(:god)]
      end

      should 'be the named speaker\'s full name followed by \"and another speaker\"' do
        assert_equal SpeakerName.new(@users).to_s, "#{@users.last.full_name} and unnamed"
      end
    end
  end
end
