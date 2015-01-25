class SpeakerName

  def initialize(speakers)
    @speakers = speakers.dup
  end

  def to_s
    @speakers.sort_by { |u| u.unnamed? ? '' : u.full_name }
        .reverse # Puts the unnamed speaker last in list
        .map(&:full_name)
        .join(' and ')
  end

end