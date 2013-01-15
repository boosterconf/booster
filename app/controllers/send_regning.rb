require 'securerandom'

class SendRegning

  #Needs to support both email and paper invoice
  #Needs to support user genereated reference
  #Needs to support multiple order lines
  #Participant name must be part of order line description.

  def initialize(test)
    @client = Sendregning::Client.new('kontakt@boosterconf.no', 'jySGOHz7', :test => test)
  end

  def self.invoice_person(invoice)
    batch_id = SecureRandom.uuid

    invoice = @client.new_invoice(
        :name => invoice.recipient_name,
        :zip => invoice.zip,
        :city => invoice.city,
        :shipment => :email,
        :emailaddresses => invoice.email
    )

    invoice.add_line :qty => 1, :desc => 'Pony', :unitPrice => '1.00'

    invoice.send!

    id = invoice.invoiceNo

    puts invoice.inspect

    id
  end


end