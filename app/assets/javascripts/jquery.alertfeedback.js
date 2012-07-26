var sb;

if (sb == null) {
  sb =  {}
}

sb.close_alert = function() {
  var alert = $('.alert');
  alert.slideUp();
}

$(function () {
  var alert = $('.alert');
  if (alert.length > 0) {
    alert.show().animate({height: alert.outerHeight()}, 200);

    window.setTimeout(function() {
      alert.slideUp();
    }, 5000);
  }

  $('.toast-item-close').live('click', sb.close_alert);
});

