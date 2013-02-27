class NametagsController < ApplicationController

  before_filter :require_admin

  def index
    @registrations = User.all(:include => :registration, :order => "name, created_at DESC")

    #prawnto :prawn => {
    #    :page_layout => :portrait,
    ##    :page_size => 'A6',
    #    :margin=>0 }
  end

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf do
        pdf = NametagPdf.new(@user, view_context)
        send_data pdf.render, filename:
            "invoice_#{@user.id}.pdf",
                  type: "application/pdf"
      end
    end
  end

end

class NametagPdf < Prawn::Document
  def initialize(user, view)
    super(:page_size => "A6", :margin => 0)

    fill_color "f2f0e6"
    rectangle [0, 600], 400, 600
    fill

    image "#{Rails.root}/app/assets/images/nametag-top.png", :width => 300
    move_down 20

    font 'Helvetica'
    fill_color "1790A0"
    font_size 24
    text user.name, :align => :center

    move_down 10
    font_size 13
    fill_color "6D6C69"
    text user.company, :align => :center

    image "#{Rails.root}/app/assets/images/nametag-bottom.png", :width => 300, :at => [0,80]

  end
end