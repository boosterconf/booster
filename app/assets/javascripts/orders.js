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
});