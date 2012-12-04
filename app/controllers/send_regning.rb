require 'securerandom'

class SendRegning

  def self.invoice_person(client_id, recipient_name, email, zipcode, city, ticket_type, ticket_price)
    batch_id = SecureRandom.uuid
    client = Sendregning::Client.new('kontakt@boosterconf.no', 'jySGOHz7', :test => true)

    invoice = client.new_invoice(
        :name => recipient_name,
        :zip => zipcode,
        :city => city,
        :shipment => :email,
        :emailaddresses => email
    )

    invoice.add_line :qty => 1, :desc => 'Pony', :unitPrice => '1.00'

    invoice.send!

    id = invoice.invoiceNo

    puts invoice.inspect

    id
  end


end