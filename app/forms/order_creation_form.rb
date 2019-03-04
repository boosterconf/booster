class TicketFikenProductValidator < ActiveModel::Validator
	def validate(record)
		record.tickets.each do |ticket|
			if(!ticket.ticket_type.has_fiken_product_reference?)
				record.errors.add :tickets, "ticket type #{ticket.ticket_type.name} lacks fiken product connection"
			end
		end
	end
end
class OrderFikenInvoiceIdValidator < ActiveModel::Validator
	def validate(record)

		matching_sales = Fiken.get_current.sales.select { |sale| sale.identifier == record.fiken_existing_sale_invoice_id}
		if(matching_sales.count > 1)
			record.errors.add :fiken_existing_sale_invoice_id, "matches multiple sales"
		end
		if(matching_sales.count < 1)
			record.errors.add :fiken_existing_sale_invoice_id, "could not be found"
		end
	end
end

class OrderCreationForm
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :tickets, Array[Ticket]

  validates :tickets, :presence => true
  validates_with TicketFikenProductValidator

  attribute :fiken_existing_sale_invoice_id, String
  validates_with OrderFikenInvoiceIdValidator, unless: Proc.new { |form| form.new_order }
  attribute :new_order, Axiom::Types::Boolean, default: true

  attribute :new_customer, Axiom::Types::Boolean, default: false
  attribute :customer_details, Fiken::Contact
  validates :customer_details, presence: true, if: :new_customer
  attribute :fiken_customer_uri, String
  attribute :fiken_bank_account_uri, String



  def ticket_ids=(ids)
  	self.tickets = Ticket.where(id: ids).all
  end

  def ticket_ids
  	self.tickets.map(&:id)
  end

  def fiken_existing_sale_uri
  	matching_sales = Fiken.get_current.sales.select { |sale| sale.identifier == fiken_existing_sale_invoice_id}
  	if(matching_sales.count == 1)
  		return matching_sales.first.href
  	else
  		return nil
  	end
  end

  def persisted?
    false
  end
end