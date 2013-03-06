class NametagsController < ApplicationController

  before_filter :require_admin

  def index
    @users = User.all(:include => :registration, :order => "name, created_at DESC")

    respond_to do |format|
      format.html
      format.pdf do
        pdf = NametagPdf.new(@users, view_context)
        send_data pdf.render,
                  filename: "nametags.pdf",
                  type: "application/pdf"
      end
    end
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf do
        pdf = NametagPdf.new([@user], view_context)
        send_data pdf.render,
                  filename: "invoice_#{@user.id}.pdf",
                  type: "application/pdf"
      end
    end
  end

end

class NametagPdf < Prawn::Document
  def initialize(users, view)
    super(:page_size => "A6", :margin => 30)


    font_families.update("siri" => {
        :normal => "#{Rails.root}/app/assets/fonts/siriregular.ttf",
        :italic => "#{Rails.root}/app/assets/fonts/siriitalic.ttf",
        :bold => "#{Rails.root}/app/assets/fonts/siribold.ttf",
        :bold_italic => "#{Rails.root}/app/assets/fonts/siribolditalic.ttf"
    })

    users.each_with_index do |user, index|
      fill_color "f2f0e6"

      rectangle [-30, 390], 298, 420
      fill

      image "#{Rails.root}/app/assets/images/nametag-top.png", :width => 300, at: [-30, 390]
      move_down 80


      font 'siri'

      fill_color "1790A0"
      font_size 26
      text user.name||'', :align => :center, :style => :bold

      move_down 10
      font_size 15
      fill_color "6D6C69"
      text user.company||'', :align => :center, :style => :normal

      move_down 150

      fill_color "F6AB6F"
      registration = user.registration
      ticket_type_text = ''
      if registration == NIL
        ticket_type_text = ''
      elsif registration.ticket_type_old == 'organizer'
        ticket_type_text = 'Organizer'
      elsif registration.speaker?
        ticket_type_text = 'Speaker'
      elsif registration.ticket_type_old == 'volunteer'
        ticket_type_text = 'Volunteer'
      elsif registration.ticket_type_old == 'student'
        ticket_type_text ='Student'
      elsif registration.ticket_type_old == 'guest'
        ticket_type_text ='Gjest - begrenset adgang'
      end

      text_box ticket_type_text, :at => [0, 80], :align => :center

      image "#{Rails.root}/app/assets/images/nametag-bottom.png", :width => 290, :at => [-25,60]

      if index < users.size - 1
        start_new_page
      end
    end
  end
end