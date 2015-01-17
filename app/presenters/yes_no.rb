class YesNo

  def initialize(boolean)
    @yesno = boolean ? 'Yes' : 'No'
  end

  def to_s
    @yesno
  end

end