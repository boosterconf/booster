jQuery.fn.setEqualHeight = function (o) {
    var maxHeight = 0;
    var maxElement = null;
    jQuery(this).each(function (i) {
        if ((jQuery(this).height() + parseInt(jQuery(this).css("padding-bottom")) + parseInt(jQuery(this).css("padding-top"))) > maxHeight) {
            maxHeight = jQuery(this).height() + parseInt(jQuery(this).css("padding-top")) + parseInt(jQuery(this).css("padding-bottom"));
            maxElement = this;
        }
    });
    jQuery(this).not($(maxElement)).each(function () {
        $(this).height(maxHeight - parseInt(jQuery(this).css("padding-top")) - parseInt(jQuery(this).css("padding-bottom")))
    })
}
