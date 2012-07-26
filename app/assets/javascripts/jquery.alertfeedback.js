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
  sb.flash_element(alert);
  var notice = $('.notice');
  sb.flash_element(notice);
});

sb.flash_element = function(element) {
  if (element.length > 0) {
    element.show().animate({height: element.outerHeight()}, 200);

    window.setTimeout(function() {
      element.slideUp();
    }, 5000);
  }

  element.find('.toast-item-close').live('click', function(){element.slideUp();});  
}