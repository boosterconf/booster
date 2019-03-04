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

    $("#order-tickets").tablesorter({
      theme: 'blue',
      // use save sort widget
      widgets: ["saveSort"]
    });

    $("#order-tickets").sieve({
      itemSelector: 'tbody tr',
      textSelector: 'td:not(.no-filter), td select option[selected]',
      searchTemplate: "<div><label>Search: <input type='text'></label></div>"
    });
});