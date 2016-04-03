class NametagsController < ApplicationController

  before_filter :require_admin

  def index
    @users = User.all(:include => :registration, :order => "last_name, created_at DESC")

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
    super(:page_size => "A6", :margin => 20)


    font_families.update("VAGRounded" => {
        :normal => "#{Rails.root}/app/assets/fonts/VAGRounded-Light.ttf"
    })

    font_families.update("FiraSans" => {
        :normal => "#{Rails.root}/app/assets/fonts/FiraSans-HeavyItalic.ttf"
    })

    users.each_with_index do |user, index|
      image "#{Rails.root}/app/assets/images/nametag-background.png", :width => bounds.width + 40, :at => [-20, bounds.height + 20]

      move_down 210

      font 'VAGRounded'
      fill_color "303030"

      if user.full_name
        font_size 30
        text user.full_name, :align => :center
      else
        font_size 20
        text user.email || '', :align => :center
      end

      move_down 10
      font_size 15
      text user.company || '', :align => :center, :style => :normal

      move_up bounds.height

      font 'FiraSans'
      font_size 23

      fill_color "FF9966"
      registration = user.registration
      ticket_type_text = ''
      if registration == nil
        ticket_type_text = ''
      elsif registration.ticket_type_old == 'organizer'
        ticket_type_text = 'ORGANIZER'
      elsif registration.user.confirmed_speaker?
        ticket_type_text = 'SPEAKER'
      elsif registration.ticket_type_old == 'volunteer'
        ticket_type_text = 'VOLUNTEER'
      elsif registration.ticket_type_old == 'student'
        ticket_type_text ='STUDENT'
      elsif registration.ticket_type_old == 'academic'
        ticket_type_text ='ACADEMIC'
      elsif registration.ticket_type_old == 'guest'
        ticket_type_text ='GUEST - LIMITED ACCESS'
      end

      text_box ticket_type_text, :at => [0, 30], :align => :center


      if index < users.size - 1
        start_new_page
      end
    end
  end
end
