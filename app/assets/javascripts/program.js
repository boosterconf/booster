$(document).ready(function () {

  showDay(1);

  $('#choose-day1').on('click', function (e) {
    e.preventDefault();
    showDay(1);
  });

  $('#choose-day2').on('click', function (e) {
    e.preventDefault();
    showDay(2);
  });

  $('#choose-day3').on('click', function (e) {
    e.preventDefault();
    showDay(3);
  });

  $('#choose-all').on('click', function (e) {
    e.preventDefault();
    showAll();
  });

  $('.single-talk').on('click', function (e) {
    if (document.documentElement.clientWidth <= 798) {
      e.preventDefault();
      $(".description").hide();
      $.when( $(this).find(".description").toggle()).then(function() {
        $(document).trigger('updateStickies');
      })
    }
  });

});

function StickyTitles(stickies) {

  var thisObj = this;
  thisObj.load = function () {

    stickies.each(function () {
      var thisSticky = jQuery(this).wrap('<div class="follow-wrapper" />');
      thisSticky.parent().height(thisSticky.outerHeight());
      jQuery.data(thisSticky[0], 'pos', thisSticky.offset().top);
    });

    jQuery(window).off("scroll.stickies").on("scroll.stickies", function () {
      thisObj.scroll();
    });

    $(document).on('updateStickies', function (e) {
      thisObj.calculatePositions(stickies);
    });
  };

  thisObj.calculatePositions = function (stickies) {
    stickies.each(function () {
      var thisSticky = jQuery(this);
      thisSticky.parent().height(thisSticky.outerHeight());
      jQuery.data(thisSticky[0], 'pos', thisSticky.offset().top);
    });
  };

  thisObj.scroll = function () {
    stickies.each(function (i) {
      var thisSticky = jQuery(this),
        nextSticky = stickies.eq(i + 1),
        prevSticky = stickies.eq(i - 1),
        pos = jQuery.data(thisSticky[0], 'pos');

      if (pos <= jQuery(window).scrollTop()) {
        thisSticky.addClass("fixed");

        if (nextSticky.length > 0 && thisSticky.offset().top >= jQuery.data(nextSticky[0], 'pos') - thisSticky.outerHeight()) {
          thisSticky.addClass("absolute").css("top", jQuery.data(nextSticky[0], 'pos') - thisSticky.outerHeight());
        }

      } else {

        thisSticky.removeClass("fixed");

        if (prevSticky.length > 0 && jQuery(window).scrollTop() <= jQuery.data(thisSticky[0], 'pos') - prevSticky.outerHeight()) {
          prevSticky.removeClass("absolute").removeAttr("style");
        }
      }
    });
  }
}

var showDay = function (dayNumber) {
  hideAllDays();
  $("#day" + dayNumber).show();

  deleselectAllDays();
  $("#choose-day" + dayNumber).parent().addClass("active");
  new StickyTitles($("#day" + dayNumber + " .follow-me")).load();
};

var showAll = function () {
  $('#day1').show();
  $('#day2').show();
  $('#day3').show();
  $('#choose-day3').parent().removeClass("active");
  $('#choose-day2').parent().removeClass("active");
  $('#choose-day1').parent().removeClass("active");
  $('#choose-all').parent().addClass("active");

  new StickyTitles($(".follow-me")).load();
};

var hideAllDays = function () {
  days = ['#day1', '#day2', '#day3'];

  var i;
  for (i = 0; i < days.length; i++) {
    var day = days[i];
    $(day).hide();
  }
};

var deleselectAllDays = function () {
  days = ['#choose-day1', '#choose-day2', '#choose-day3', '#choose-all'];

  var i;
  for (i = 0; i < days.length; i++) {
    var day = days[i];
    $(day).parent().removeClass("active");
  }
};