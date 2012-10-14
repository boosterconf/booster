require 'test_helper'

class TagTest < ActiveSupport::TestCase

  def test_only_known_tags_should_not_create_new_tags
    assert_no_difference('Tag.count') do
      Tag.create_and_return_tags(["agile", "testing"])
    end
  end

  def test_unknown_tags_should_be_created
    assert_difference('Tag.count', +1) do
      Tag.create_and_return_tags(["new_tag"])
    end
  end
  
  def test_case_differences_should_be_ignored
    assert_no_difference('Tag.count') do
      Tag.create_and_return_tags(["Agile", "Testing"])
    end
  end

  def test_should_return_all_tag_names_as_tags
    tags = Tag.create_and_return_tags(["agile", "new_tag"])
    assert tags.size == 2
    assert tags.include? tags(:agile)
    assert tags.map { |tag| tag.title }.include? "new_tag"
  end

end