class OrdersController < AdminController

	def index
		@orders = Order.includes(:tickets).all
		@sales_urls_map = Fiken.get_current.sales.inject({}) do |result, sale|
			result[sale.href] = sale.ui_url
			result
		end
	end

	def new
		@customers = find_customers
		@bank_accounts = find_bank_accounts
		@new_order_request = OrderCreationForm.new
	end

	def create
		service = TicketOrderingService.new

		@customers = find_customers
		@bank_accounts = find_bank_accounts
		@new_order_request = OrderCreationForm.new(order_creation_form_params)
		if(service.create_order_for_tickets(@new_order_request))
			redirect_to orders_path
		else
			render action: :new
		end
	end

	def destroy
		@order = Order.find_by_id(params[:id])
		@order.destroy!
		redirect_to orders_path
	end

	private

	def order_creation_form_params
		params.require(:order_creation_form).permit!
	end

	def find_customers
		Fiken.get_current
					.contacts
					.select {|c| c.customer_number.present? }
					.map { |customer| [customer.name, customer.href]}
	end

	def find_bank_accounts
		Fiken.get_current
					.bank_accounts
					.map { |bank_account| [bank_account.descriptive_name, bank_account.href]}
	end
end