class ReceiptsController < ApplicationController

  #before_action :require_admin

  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf do
        pdf = ReceiptPdf.new(@user.registration, view_context)
        send_data pdf.render,
                  filename: "receipt_#{@user.id}.pdf",
                  type: "application/pdf"
      end
    end
  end

end

class ReceiptPdf < Prawn::Document
  def initialize(registration, view)
    super(:page_size => "A4", :margin => 30)

    font_families.update("siri" => {
        :normal => "#{Rails.root}/app/assets/fonts/siriregular.ttf",
        :italic => "#{Rails.root}/app/assets/fonts/siriitalic.ttf",
        :bold => "#{Rails.root}/app/assets/fonts/siribold.ttf",
        :bold_italic => "#{Rails.root}/app/assets/fonts/siribolditalic.ttf"
    })

    image "#{Rails.root}/app/assets/images/receipt-top.png", :width => 200, :position => :right
    move_down 20

    font 'siri'
    font_size 12

    fill_color "404040"
    text "Foreningen Boosterkonferansen", :align => :right
    text "NO 997 448 243 MVA", :align => :right
    text "c/o Miles AS", :align => :right
    text "O.J. Brochs gate 16 A", :align => :right
    text "5006 BERGEN", :align => :right

    move_down 20

    text ""
    text "Fakturanr: "
    text "Fakturadato: " + registration.created_at.strftime("%Y-%m-%d")

    move_down 20

    text registration.user.company
    text registration.user.full_name
    text registration.user.email

    move_down 50


    font_size 18
    text "Faktura", :style => :bold

    font_size 12

    move_down 20

    paid = registration.paid_amount || 0.0
    price = paid / 1.25
    mva = paid - price;

    format = "%3.2f"

    data = []
    data << ["Varetekst", "mva", "ant", "pris", "sum"]
    data << [registration.ticket_description, "25%", 1, format % price, format % price]
    data << ["Mva", "", "", "", format % mva]
    data << ["Totalt", "", "", "", format % paid]


    table(data, :column_widths => [295, 60, 60, 60, 60]) do
      header = true
      cells.borders = []

      rows(0).background_color = 'f2f0e6'
      rows(0).borders = [:bottom]
      rows(-1).background_color = 'f2f0e6'
      rows(-1).borders = [:top, :bottom]
    end



    fill_color "1790A0"

    fill_color "F6AB6F"

    fill_color "f2f0e6"

    rectangle [-31,80], 600, 120
    fill

    image "#{Rails.root}/app/assets/images/receipt-bottom.png", :width => 290, :at => [-25,60]
  end
end