$(document).ready(function () {
        $('#manual_payment input').on('click', function (event) {
            $('#invoice_fields').fadeIn();
            $('#register_submit input').val('Register');
        });

        $('#paypal input').on('click', function (event) {
            $('#invoice_fields').fadeOut();
            $('#register_submit input').val('Register and proceed to payment');
        });

    }
);