class NametagsController < ApplicationController

  before_filter :require_admin

  def index
    @tickets = Ticket.all(:include => :ticket_type)

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
    super(:page_size => "A6", :margin => 20)


    font_families.update("VAGRounded" => {
        :normal => "#{Rails.root}/app/assets/fonts/VAGRounded-Light.ttf"
    })

    font_families.update("FiraSans" => {
        :normal => "#{Rails.root}/app/assets/fonts/FiraSans-HeavyItalic.ttf"
    })

    tickets.each_with_index do |ticket, index|
      image "#{Rails.root}/app/assets/images/nametag-background.png", :width => bounds.width + 40, :at => [-20, bounds.height + 20]

      move_down 210

      font 'VAGRounded'
      fill_color "303030"

      if ticket.name
        font_size 30
        text ticket.name, :align => :center
      else
        font_size 20
        text ticket.email || '', :align => :center
      end

      move_down 10
      font_size 15
      text ticket.company || '', :align => :center, :style => :normal

      move_up bounds.height

      font 'FiraSans'
      font_size 23

      fill_color "FF9966"
      ticket_type_text = ''
      if ticket.ticket_type.organizer?
        ticket_type_text = 'ORGANIZER'
      elsif ticket.ticket_type.speaker?
        ticket_type_text = 'SPEAKER'
      elsif ticket.ticket_type.volunteer?
        ticket_type_text = 'VOLUNTEER'
      elsif ticket.ticket_type.student?
        ticket_type_text ='STUDENT'
      end

      text_box ticket_type_text, :at => [0, 30], :align => :center

      if index < tickets.size - 1
        start_new_page
      end
    end
  end
end
