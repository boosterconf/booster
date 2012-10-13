module TalksHelper

  def contains_html(string)
    string =~ /<\/?\w+\s?>/
  end

end