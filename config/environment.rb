# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Booster2013::Application.initialize!

ActionView::Base.field_error_proc = proc {|html, instance| html }

ActionMailer::Base.delivery_method = :smtp
