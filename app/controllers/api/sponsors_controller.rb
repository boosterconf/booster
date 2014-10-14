module Api
  class SponsorsController < ApplicationController

    respond_to :json

    before_filter :find_sponsor, only: [:email]

    def email
      @number_of_sponsors_per_user = @sponsors.group_by(&:user).map { |user, sponsors| [user != nil ? user.full_name : "(none)", sponsors.length] }.sort { |a, b| a[1] <=> b[1] }.reverse!
      @events = Event.last(15).reverse

      if @sponsor.is_ready_for_email?
        BoosterMailer.initial_sponsor_mail(@sponsor).deliver
        @sponsor.status = 'contacted'
        @sponsor.last_contacted_at = Time.now.to_datetime
        if @sponsor.save
          event = Event.new(:user => current_user, :sponsor => @sponsor, :comment => "Email sent")
          event.save

          respond_to do |format|
            format.json { respond_with @sponsor }
            format.js {
              flash[:notice] = "Email sent and status for #{@sponsor.name} changed to #{Sponsor::STATES[@sponsor.status]} "
              render 'sponsors/update'
            }
          end

        else

          head :internal_server_error
        end
      else
        head :bad_request
      end
    end

    private
    def find_sponsor
      @sponsor = Sponsor.find(params[:sponsor_id])
    end
  end
end