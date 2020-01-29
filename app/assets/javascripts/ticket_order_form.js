function paymentDetailsChanged(input) {
	if(input.val() == "invoice") {
		$("#invoice_fields").show();
	} else {
		$("#invoice_fields").hide();
	}
	if(input.val() == "company_group_invoice") {
		$("#company_invoice_fields").show();
	} else {
		$("#company_invoice_fields").hide();
	}
}

$(document).ready(function() {
	$("input[name='ticket_order_form[payment_details_type]']").change(function(e){
		paymentDetailsChanged($(this))
	})
	paymentDetailsChanged($("input[name='ticket_order_form[payment_details_type]']:checked"))

})