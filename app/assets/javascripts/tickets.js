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