class NametagsController < ApplicationController

  before_action :require_admin

  def index
    @tickets = Ticket.includes(:ticket_type)

    respond_to do |format|
      format.html
      format.pdf do
        pdf = NametagPdf.new(@tickets, view_context)
        send_data pdf.render,
                  filename: "nametags.pdf",
                  type: "application/pdf"
      end
    end
  end

  def show
    @ticket = Ticket.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf do
        pdf = NametagPdf.new([@ticket], view_context)
        send_data pdf.render,
                  filename: "nametag_#{@ticket.id}.pdf",
                  type: "application/pdf"
      end
    end
  end

end

class NametagPdf < Prawn::Document
  def initialize(tickets, view)
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

    tickets.each_with_index do |ticket, index|
      image "#{Rails.root}/app/assets/images/nametag-background.png", :width => bounds.width + 70, :at => [-35, bounds.height + 35]


      move_down 30

      fill_color "00333f"
      font 'FiraSansLight'


      if ticket.name
        font_size 35
        text ticket.name, :align => :center, :width => 250
      else
        font_size 35
        text ticket.email || '', :align => :center
      end

      move_down 15

      font 'FiraSansMedium'
      font_size 17

      text ticket.company || '', :style => :normal, :align => :center

      move_up bounds.height

      fill_color "FFFFFF"
      font 'FiraSansMedium'

      font_size 15

      ticket_type_text = ''
      if ticket.ticket_type.organizer?
        fill_color 'DE9777'
        fill_rectangle [-35, 0], 300, 80
        ticket_type_text = 'ORGANIZER'
      elsif ticket.ticket_type.speaker?
        fill_color 'D8DFDE'
        fill_rectangle [-35, 0], 300, 80
        ticket_type_text = 'SPEAKER'
      elsif ticket.ticket_type.volunteer?
        fill_color 'A8D1C5'
        fill_rectangle [-35, 0], 300, 80
        ticket_type_text = 'VOLUNTEER'
      elsif ticket.ticket_type.student?
        ticket_type_text = ''
      end


      fill_color "FFFFFF"
      text_box ticket_type_text, :at => [0, -10], :align => :center, :height => 50

      if index < tickets.size - 1
        start_new_page
      end
    end
  end
end
