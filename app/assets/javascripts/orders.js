$(document).ready(function() {
	$(".new-order-field").change(function(){
		if($(this).prop("checked")) {
			if($(this).prop("value") == "true") {
				$('#new-sale-fieldset').show();
				$('#existing-sale-fieldset').hide();
				console.log("checked");
			} else {
				$('#new-sale-fieldset').hide();
				$('#existing-sale-fieldset').show();
				console.log("not checked");
			}
		}
	}).change();
});