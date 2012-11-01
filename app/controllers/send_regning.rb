require 'rest_client'
require 'securerandom'

class SendRegning

  def send_invoice(url, client_id, recipient_name, email, zipcode, city, ticket_type, ticket_price)
    batch_id = SecureRandom.uuid
    xml = <<XML
            <?xml version="1.0" encoding="UTF-8"?>
              <invoices batchId="#{batch_id}">
              <invoice clientId="#{client_id}">
                <name>#{recipient_name}</name>
                <zip>#{zipcode}</zip>
                <city>#{city}</city>
                <lines>
                  <line>
                    <itemNo>1</itemNo>
                    <qty>1.00</qty>
                    <prodCode>#{ticket_type}</prodCode>
                    <desc>Booster 2013 Conference Ticket</desc>
                    <unitPrice>#{ticket_price}</unitPrice>
                    <discount>0.00</discount>
                    <tax>25</tax>
                  <line>
                <lines>
                <optional>
                  <recipientNo>#{client_id}</recipientNo>
                  <email>#{email}</email>
                </optional>
                <shipment>
                  EMAIL
                  <emailaddresses>
                    <email>#{email}</email>
                  </emailaddresses>
                </shipment>
              </invoice>
            </invoices>
XML
    response = RestClient.post url, { 'body' => xml }.to_xml
    # What is a successful payment?
    p response inspect
    response.code < 400
  end

end