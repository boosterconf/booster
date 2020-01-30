class OrdersController < ApplicationController

	before_action :require_admin, except: [:show]

	def index
		@orders = Order.all
		fiken_company = Fiken.get_current
		current_sales = fiken_company.sales
		@sales_urls_map = current_sales.inject({}) do |result, sale|
			result[sale.href] = sale.ui_url
			result
		end

		current_contacts = fiken_company.contacts
		@sales_customer_map = current_sales.inject({}) do |result, sale|
			result[sale.href] = current_contacts.select { |contact| contact.href == sale.customer }.first
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

	def show
		@order = Order.find_by_id!(params[:id])
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