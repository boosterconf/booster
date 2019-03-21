require "securerandom"

class RegisterKeynoteController < ApplicationController
  include CfpClosedRedirect

  before_action :require_admin, :only => [:invited_talk, :create_invited_talk]

  def invited_talk
    @talk = Keynote.new
  end

  def create_invited_talk

    @talk = Keynote.new(talk_params)
    @talk.talk_type = TalkType.find_by_name("Keynote")
    @talk.accept!
    if @talk.save
      SlackNotifier.notify_talk(@talk)

      redirect_to talk_path(@talk)
    else
      render action: :invited_talk
    end
  end

  private

  def talk_params
    (current_user&.is_admin?) ?
        params.require(:talk).permit! :
        params.require(:talk).permit(:talk_type_id, :title, :description, :equipment, :appropriate_for_roles,
                                     :outline, :max_participants, :speaking_history, :participant_requirements, :equipment, :additional_speaker_email)
  end

end
