class NametagsController < ApplicationController

  before_action :require_admin

  def index
    @tickets = Ticket.includes(:ticket_type)
    @users = User.all_from_ticket_email.to_a

    respond_to do |format|
      format.html
      format.pdf do
        pdf = NametagPdf.new(@tickets, @users, view_context)
        send_data pdf.render,
                  filename: "nametags.pdf",
                  type: "application/pdf"
      end
    end
  end

  def show
    @ticket = Ticket.find(params[:id])
    @users = User.find_by_email(@ticket.email).includes(:bio)

    respond_to do |format|
      format.html
      format.pdf do
        pdf = NametagPdf.new([@ticket], @users, view_context)
        send_data pdf.render,
                  filename: "nametag_#{@ticket.id}.pdf",
                  type: "application/pdf"
      end
    end
  end

end

class NametagPdf < Prawn::Document
  def initialize(tickets, users, view)
    super(:page_size => "A6", :margin => 35)

    font_families.update("FiraSans" => {
        :normal => "#{Rails.root}/app/assets/fonts/FiraSans-Heavy.ttf"
    })

    font_families.update("FiraSansMedium" => {
        :normal => "#{Rails.root}/app/assets/fonts/FiraSans-Medium.ttf"
    })

    font_families.update("FiraSansLight" => {
        :normal => "#{Rails.root}/app/assets/fonts/FiraSans-Light.ttf"
    })

    font_families.update("FiraSansLightItalic" => {
        :normal => "#{Rails.root}/app/assets/fonts/FiraSans-LightItalic.ttf"
    })

    tickets.each_with_index do |ticket, index|
      image "#{Rails.root}/app/assets/images/nametag-background-blue.png", :width => bounds.width + 70, :at => [-35, bounds.height + 35]


      move_down 30

      fill_color "00333f"
      font 'FiraSansLight'


      if ticket.name
        font_size 35
        text ticket.name, :align => :center, :width => 400
      else
        font_size 35
        text ticket.email || '', :align => :center
      end

      move_down 15

      font 'FiraSansLightItalic'
      font_size 17

      text ticket.company || '', :style => :normal, :align => :center

      @user = users.bsearch{|u| u.email == ticket.email}
      if @user
        if @user.twitter_handle

          move_down 15

          font 'FiraSansMedium'
          font_size 17

          if @user.twitter_handle.include? "@"
            text @user.twitter_handle || '', :style => :normal, :align => :center
          else
            text "@" + @user.twitter_handle || '', :style => :normal, :align => :center
          end
        end
      end


      move_up bounds.height

      fill_color "FFFFFF"
      font 'FiraSansMedium'

      font_size 15

      ticket_type_text = ''
      if ticket.ticket_type.organizer?
        ticket_type_text = 'ORGANIZER'
      elsif ticket.ticket_type.speaker?
        ticket_type_text = 'SPEAKER'
      elsif ticket.ticket_type.volunteer?
        ticket_type_text = 'VOLUNTEER'
      elsif ticket.ticket_type.student?
        ticket_type_text = ''
      end


      fill_color "FFFFFF"
      text_box ticket_type_text, :at => [0, -5], :align => :center, :height => 50

      if index < tickets.size - 1
        start_new_page
      end
    end
  end
end
