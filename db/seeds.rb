require 'active_record/fixtures'
ActiveRecord::FixtureSet.create_fixtures("#{Rails.root}/db/fixtures", %w(talk_types))
ActiveRecord::FixtureSet.create_fixtures("#{Rails.root}/db/fixtures", %w(ticket_types))