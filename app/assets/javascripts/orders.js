$(document).ready(function() {
	$(".new-order-field").change(function(){
		if($(this).prop("checked")) {
			if($(this).prop("value") == "true") {
				$('#new-sale-fieldset').show();
				$('#existing-sale-fieldset').hide();
			} else {
				$('#new-sale-fieldset').hide();
				$('#existing-sale-fieldset').show();
			}
		}
	}).change();
	$(".new-customer-field").change(function(){
		if($(this).prop("checked")) {
			if($(this).prop("value") == "true") {
				$('#existing-customer-form-group').hide();
				$('#new-customer-form-group').show();
			} else {
				$('#new-customer-form-group').hide();
				$('#existing-customer-form-group').show();
			}
		}
	}).change();
});