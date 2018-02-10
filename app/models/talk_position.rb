class TalkPosition < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :talk
  belongs_to :slot

end