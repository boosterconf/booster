class InvoicePdf
  def self.generate(tickets, stripe_charge, invoice_details)
    Prawn::Document.generate('invoice_details.pdf', :page_size => 'A4') do
      font "Courier"
      pad(20) {
        text "Invoice details Booster #{Dates::CONFERENCE_YEAR} tickets",
             :size => 20 }
      stroke_horizontal_rule
      if stripe_charge
        pad_top(20) { text "Stripe payment:".ljust(20) + "#{stripe_charge.id}" }
        pad_bottom(20) { text "Payment status:".ljust(20) + "#{stripe_charge.paid ? 'Paid' : 'Payment failed'}" }
      else
        pad_top(20) { text "Invoice reference:".ljust(20) + "#{invoice_details[:payment_info]}" }
        text "Invoice ZIP:".ljust(20) + "#{invoice_details[:payment_zip]}"
        pad_bottom(20) { text "Send to:".ljust(20) + "#{invoice_details[:payment_email]}" }
      end
      stroke_horizontal_rule
      font
      pad_top(20) { text "Description".ljust(35) + "VAT".ljust(15) + "Amount".ljust(15), :style => :bold }
      pad_bottom(20) { stroke_horizontal_rule }
      tickets.each { |ticket|
        text ticket.ticket_type.name.ljust(35) + "#{ticket.ticket_type.vat} NOK".ljust(15) + "#{ticket.ticket_type.price} NOK".ljust(15)
      }
      pad_top(20) { stroke_horizontal_rule }
      total = tickets.inject(0) { |sum, t| sum + t.ticket_type.price_with_vat }
      pad(20) { text 'Total (incl. VAT)'.ljust(35) + ''.ljust(15) + "#{total} NOK".ljust(15), :style => :bold }
    end
  end
end