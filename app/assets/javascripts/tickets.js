$(document).ready(function () {
    $("#submit_invoice").on("click", function (e) {
        var notFilledOut = $("[required=required]").filter(function (index, el) {
            return !$(el).val();
        });
        if (notFilledOut.length === 0) {
            $("#submit_invoice").closest("form").submit();
            e.preventDefault();
        }
    });
});