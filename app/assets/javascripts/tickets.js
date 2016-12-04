$(document).ready(function () {
    $("#submit_invoice").on("click", function (e) {
        $("#submit_invoice").closest("form").submit();
        e.preventDefault();
    });
});