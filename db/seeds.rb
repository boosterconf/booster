require 'active_record/fixtures'
ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/db/fixtures", %w(talk_types ticket_types))