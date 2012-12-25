# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Booster2013::Application.initialize!

## We do not want to leak user names, so for login
## do not mark the fields with errors, just display
## a generic message instead.
ActionView::Base.field_error_proc = proc do |html, instance|
  if instance.object_name == 'user_session'
    html
  else
    if html =~ /^<label/
      html = %(<div class="clearfix error">#{html}</div>).html_safe
    elsif html =~ /<input|<textarea/
      if instance.error_message.kind_of?(Array)
        html = %(<div class="clearfix error">#{html}<span class="help-inline">&nbsp;#{instance.error_message.join(',')}</span></div>).html_safe
      else
        html = %(<div class="clearfix error">#{html}<span class="help-inline">&nbsp;#{instance.error_message}</span></div>).html_safe
      end
    end
    html
  end
end
