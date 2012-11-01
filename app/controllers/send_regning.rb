class SendRegning

  xml = <<XML
  <?xml version="1.0" encoding="UTF-8"?>
    <invoices batchId="#{batchId}">
    <invoice clientId="#{clientId}">
      <name>#{recipientName}</name>
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
        <recipientNo>#{clientId}</recipientNo>
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

end