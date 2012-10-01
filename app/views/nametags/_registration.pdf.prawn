require 'prawn/layout'
require 'prawn/format'


p_pdf.font_families.update(
    "League Gothic" => { :normal => "#{Rails.root}/public/stylesheets/League_Gothic-webfont.ttf" },
    "Blackout" => { :normal => "#{Rails.root}/public/stylesheets/Blackout-Midnight-webfont.ttf" }
)

p_pdf.font 'League Gothic'
p_pdf.fill_color 'e0e0e0'
p_pdf.text 'Roots 2012',
    :at => [105, 30],
    :overflow => :truncate,
    :size => 55

p_pdf.font 'League Gothic'
p_pdf.fill_color '5bbc6d'

name = registration.user.name
company = registration.user.company


if (registration.ticket_type_old == 'organizer' || registration.ticket_type_old == 'volunteer') and company.downcase == 'cisco'
  p_pdf.text 'Filmcrew',
      :at => [169,80],
      :size => 36
elsif registration.ticket_type_old == 'organizer'
  p_pdf.text 'Organizer',
      :at => [168,80],
      :size => 36
elsif registration.speaker?
  p_pdf.text 'Speaker',
      :at => [178,80],
      :size => 36
elsif registration.ticket_type_old == 'volunteer'
  p_pdf.text 'Volunteer',
      :at => [160,80],
      :size => 36
elsif registration.ticket_type_old == 'mod251' || registration.ticket_type_old == 'student'
  p_pdf.text 'Student',
      :at => [178,80],
      :size => 36
elsif registration.ticket_type_old == 'guest'
  p_pdf.fill_color '0000cc'
  p_pdf.text 'Begrenset tilgang',
      :at => [80,80],
      :size => 36
end

p_pdf.fill_color 'ffffff'
p_pdf.table [[name]],
    :font_size  => 33,
    :horizontal_padding => 30,
    :vertical_padding => 50,
    :width => 297,
    :border_width => 0,
    :position => :left,
    :row_colors  => ['5bbc6d']



p_pdf.move_up 30
p_pdf.fill_color '000000'
p_pdf.table [[company]],
    :font_size  => 20,
    :horizontal_padding => 30,
    :width => 297,
    :border_width => 0,
    :position => :left,
    :row_colors  => ['ffffff']


roots_logo = "#{Rails.root}/public/images/roots-icon-cropped.png"
p_pdf.image roots_logo,
  :at => [0, 100],
  :width => 100
