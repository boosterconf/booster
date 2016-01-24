class TalkPosition < ActiveRecord::Base
  belongs_to :talk
  belongs_to :slot

  attr_accessible :talk, :slot, :talk_id, :slot_id
end