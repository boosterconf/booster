class TalkPosition < ApplicationRecord
  belongs_to :talk
  belongs_to :slot

end