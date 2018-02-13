class StatisticsController < ApplicationController

  before_action :require_admin

  def index
  end

  def users_by_company
    if params[:filter]
      case params[:filter]
        when 'speakers'
          @title = 'Antall deltakere med innsendt foredrag pr selskap'
          @companies = companies_from_users(User.all_speakers)
        when 'accepted'
          @title = 'Antall deltakere med godkjent foredrag pr selskap'
          @companies = companies_from_users(User.all_accepted_speakers)
        when 'participants'
          @title = 'Antall deltakere pr selskap (utenom aksepterte speakers)'
          @companies = companies_from_users(User.all_normal_participants)
        else
          flash[:error] = "Ukjent filter"
          @title = ""
          @companies = []
      end
    else
      @title = 'Absolutt alle deltakere, antall pr selskap'
      @companies = companies_from_users(User.all_participants)
    end
  end
  
  def companies_from_users users
    counts = users.each_with_object(Hash.new(0)) { |user,counts| counts[user.company] += 1 }
    return counts.sort_by { |name, count| count }.reverse
  end
end
