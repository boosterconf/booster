class StatisticsController < ApplicationController

  before_filter :require_admin

  def index
  end

  def users_by_company
    if params[:filter]
      case params[:filter]
        when 'speakers'
          @title = 'Antall deltakere med innsendt foredrag pr selskap'
          @companies = User.find_by_sql("SELECT company, count(*) AS num_of_participants FROM (SELECT DISTINCT u.first_name, u.last_name, u.company FROM users u INNER JOIN speakers s ON u.id = s.user_id INNER JOIN talks t ON t.id = s.talk_id ORDER BY u.company, u.last_name, u.first_name) AS s GROUP BY company ORDER BY num_of_participants DESC, company")
        when 'accepted'
          @title = 'Antall deltakere med godkjent foredrag pr selskap'
          @companies = User.find_by_sql("SELECT company, count(*) AS num_of_participants FROM (SELECT DISTINCT u.first_name, u.last_name, u.company FROM users u INNER JOIN speakers s ON u.id = s.user_id INNER JOIN talks t ON t.id = s.talk_id WHERE t.acceptance_status = 'accepted' ORDER BY u.company, u.last_name, u.first_name) AS s GROUP BY company ORDER BY num_of_participants DESC, company")
        when 'participants'
          @title = 'Antall deltakere pr selskap (ikke speakers)'
          @companies = User.find_by_sql("SELECT company, count(*) AS num_of_participants from users u inner join registrations r on u.id = r.user_id where ticket_type_old IN ('full_price', 'early_bird') GROUP BY company ORDER BY num_of_participants DESC, company")
        else
          flash[:error] = "Ukjent filter"
          @title = ""
          @companies = []
      end
    else
      @title = 'Antall deltakere pr selskap'
      @companies = User.find_by_sql("SELECT company, count(*) AS num_of_participants FROM users GROUP BY company ORDER BY num_of_participants DESC, company")
    end
  end
end