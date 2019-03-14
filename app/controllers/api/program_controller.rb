module Api
  class ProgramController < ApplicationController

    respond_to :json

    def index
      unless AppConfig.program_released || current_user.is_admin?
        return redirect_to root_path
      end

      @periods = []
      @periods = Rails.cache.fetch(Cache::ProgramApiCacheKey, expires_in: 30.minutes) do
          # Onsdag
          @periods << {:start_time => DateTime.parse("2000-01-01T09:00:00.000Z"), :end_time => DateTime.parse("2000-01-01T09:15:00.000Z"), :day => Date.parse("2019-03-13"), :type => "organizers",
                       :talks => {"Dragefjellet" => {:title => "Welcome from the organizers", :speaker => "" }}}
          @periods << {:start_time => DateTime.parse("2000-01-01T09:15:00.000Z"), :end_time => DateTime.parse("2000-01-01T10:15:00.000Z"), :day => Date.parse("2019-03-13"), :type => "keynote",
                       :talks => {"Dragefjellet" => {:title => "Keynote:Embidies vulnerabilities - Why I am hacking my own heart", :speaker => "Marie Moe"}}}
          @periods << {:start_time => DateTime.parse("2000-01-01T11:15:00.000Z"), :end_time => DateTime.parse("2000-01-01T11:30:00.000Z"), :day => Date.parse("2019-03-13"), :type => "Coffee Break", :talks => nil}
          @periods << {:start_time => DateTime.parse("2000-01-01T12:15:00.000Z"), :end_time => DateTime.parse("2000-01-01T13:30:00.000Z"), :day => Date.parse("2019-03-13"), :type => "Lunch", :talks => nil}
          @periods << {:start_time => DateTime.parse("2000-01-01T15:00:00.000Z"), :end_time => DateTime.parse("2000-01-01T15:15:00.000Z"), :day => Date.parse("2019-03-13"), :type => "Coffee Break", :talks => nil}
          @periods << {:start_time => DateTime.parse("2000-01-01T19:00:00.000Z"), :end_time => DateTime.parse("2000-01-01T00:00:00.000Z"), :day => Date.parse("2019-03-13"), :type => "Conference dinner - Galleri Nygaten", :talks => nil}

          # Torsdag
          @periods << {:start_time => DateTime.parse("2000-01-01T10:30:00.000Z"), :end_time => DateTime.parse("2000-01-01T10:45:00.000Z"), :day => Date.parse("2019-03-14"), :type => "Coffee Break", :talks => nil}
          @periods << {:start_time => DateTime.parse("2000-01-01T12:15:00.000Z"), :end_time => DateTime.parse("2000-01-01T13:30:00.000Z"), :day => Date.parse("2019-03-14"), :type => "Lunch", :talks => nil}
          # Open spaces
          @periods << {:start_time => DateTime.parse("2000-01-01T13:30:00.000Z"), :end_time => DateTime.parse("2000-01-01T14:00:00.000Z"), :day => Date.parse("2019-03-14"), :type => "Dragefjellet - Introduction to open spaces", :talks => nil}
          @periods << {:start_time => DateTime.parse("2000-01-01T14:00:00.000Z"), :end_time => DateTime.parse("2000-01-01T14:45:00.000Z"), :day => Date.parse("2019-03-14"), :type => "Dragefjellet and more - Open spaces 1", :talks => nil}
          @periods << {:start_time => DateTime.parse("2000-01-01T14:45:00.000Z"), :end_time => DateTime.parse("2000-01-01T15:30:00.000Z"), :day => Date.parse("2019-03-14"), :type => "Dragefjellet and more - Open spaces 2", :talks => nil}
          # Short talks
          @periods << {:start_time => DateTime.parse("2000-01-01T15:30:00.000Z"), :end_time => DateTime.parse("2000-01-01T15:45:00.000Z"), :day => Date.parse("2019-03-14"), :type => "Coffee Break", :talks => nil}
          @periods << {:start_time => DateTime.parse("2000-01-01T16:15:00.000Z"), :end_time => DateTime.parse("2000-01-01T16:30:00.000Z"), :day => Date.parse("2019-03-14"), :type => "Coffee Break", :talks => nil}
          @periods << {:start_time => DateTime.parse("2000-01-01T19:00:00.000Z"), :end_time => DateTime.parse("2000-01-01T00:00:00.000Z"), :day => Date.parse("2019-03-14"), :type => "Speakers dinner - Grand Hotel Terminus", :talks => nil}

          #Fredag
          @periods << {:start_time => DateTime.parse("2000-01-01T10:30:00.000Z"), :end_time => DateTime.parse("2000-01-01T10:45:00.000Z"), :day => Date.parse("2019-03-15"), :type => "Coffee Break", :talks => nil}
          @periods << {:start_time => DateTime.parse("2000-01-01T12:15:00.000Z"), :end_time => DateTime.parse("2000-01-01T13:30:00.000Z"), :day => Date.parse("2019-03-15"), :type => "Lunch", :talks => nil}
          @periods << {:start_time => DateTime.parse("2000-01-01T15:00:00.000Z"), :end_time => DateTime.parse("2000-01-01T15:15:00.000Z"), :day => Date.parse("2019-03-15"), :type => "Coffee Break", :talks => nil}
          @periods << {:start_time => DateTime.parse("2000-01-01T15:15:00.000Z"), :end_time => DateTime.parse("2000-01-01T16:15:00.000Z"), :day => Date.parse("2019-03-15"), :type => "keynote",
                       :talks => {"Dragefjellet" => {:title => "Keynote: Meeting restistance and moving forward", :speaker => "Linda Rising"}}}
          @periods << {:start_time => DateTime.parse("2000-01-01T16:15:00.000Z"), :end_time => DateTime.parse("2000-01-01T16:30:00.000Z"), :day => Date.parse("2019-03-15"), :type => "organizers",
                       :talks => {"Dragefjellet" => {:title => "See you next year", :speaker => "" }}}


          all_periods = Period.all.sort_by {|period| [period.day, period.start_time]}
          all_periods.each {|period|
            talks = {}

            period.slots.each {|slot|
              if (period.period_type == 'lightning') then
                talks[slot.room.name] = {:title => "Lightning Talks", :speaker => ""}
              else
                talks[slot.room.name] = {:title => slot.talks&.first&.title, :speaker => slot.talks&.first&.speaker_name.to_s}
              end
            }

            @periods << {:start_time => period.start_time, :end_time => period.end_time, :day => period.day, :type => period.period_type, :talks => talks }
          }

          @periods = @periods.sort_by {|period| [period[:day], period[:start_time]]}
          @periods
      end

      respond_to do |format|
        format.json { respond_with @periods }
        # format.html { render json [@talks, @periods]}
      end
    end


  end
end