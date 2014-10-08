require 'test_helper'

class BioTest < ActiveSupport::TestCase

  def setup
    @bio = bios(:quentins_bio)
  end

  def test_model_sanity
    assert_equal "Chief happiness officer", @bio.title
  end

  def test_bio_belongs_to_user
    assert_equal "Quentin", @bio.user.first_name
    assert_equal "Quintinus", @bio.user.last_name
  end

  def test_user_not_featured
    assert_equal false, @bio.user.is_featured?
  end

  def test_user_featured
    user = @bio.user
    user.feature_as_speaker
    assert_equal true, user.is_featured?
  end

  def test_user_can_have_picture
    user = @bio.user
    user.bio.picture = sample_file
    assert_equal "batman.jpg", user.bio.picture_file_name
    p user.bio.picture.path
  end

  def sample_file(filename = "batman.jpg")
    File.new("test/fixtures/#{filename}")
  end

end
