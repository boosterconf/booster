class TalkPosition < ActiveRecord::Base

  belongs_to :talk
  belongs_to :slot

end