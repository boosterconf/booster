$(document).ready(function () {
    $("#primary_submit").on("click", function (e) {
        var notFilledOut = $("[required=required]").filter(function (index, el) {
            return !$(el).val();
        });
        if (notFilledOut.length === 0) {
            $("#primary_submit").closest("form").submit();
            e.preventDefault();
        }
    });
});

function paymentDetailsChanged(input) {
	if(input.val() == "invoice" || input.val() == "card") {
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

	$("input[name='ticket_order_form[attendees_attributes][0][name]']").on("change keyup", function(e) {
		$("#invoice_fields input[name='ticket_order_form[invoice_details][name]']").val($(this).val());
	});
	$("input[name='ticket_order_form[attendees_attributes][0][email]']").on("change keyup", function(e) {
		$("#invoice_fields input[name='ticket_order_form[invoice_details][email]']").val($(this).val());
	});
	$("input[name='ticket_order_form[attendees_attributes][0][company]']").on("change keyup", function(e) {
		$("#company_invoice_fields input[name='ticket_order_form[company_invoice_details][name]']").val($(this).val());
	});

})