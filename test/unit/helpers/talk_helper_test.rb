require 'test_helper'
require 'talks_helper'

class TalkHelperTest < ActionView::TestCase
  include TalksHelper

  def test_contains_html_handles_p
    assert contains_html("<p>Test</p>")
  end

  def test_contains_html_handles_empty_strings
    assert !contains_html("")
  end

  def test_contains_html_handles_string_without_html
    assert !contains_html("The Agile movement shifted the relationship between clients and developers in a profound way. In waterfall processes, clients specified large amounts of functionality, then nervously faded into the background until the fateful day‐of-delivery. With Agile, developers strove to engage with clients continuously, and delivered much more frequently against their needs. A new trust was established. At the Forward Internet Group in London, we are implementing a second major shift between clients and developers.")
  end

  def test_contains_html_handles_nested_html_tags
    assert contains_html("<p>Test Test <ul><li>one</li>/ul></p>")
  end
end
