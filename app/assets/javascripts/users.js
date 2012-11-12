$(document).ready(function () {
    $('.error input:first').focus();

    $('#manual_payment input').on('click', function (event) {
        $('#payment_details').fadeIn();
        $('#register_submit input').val('Register');
    });

    $('#paypal input').on('click', function (event) {
        $('#payment_details').fadeOut();
        $('#register_submit input').val('Register and proceed to payment');
    });
});