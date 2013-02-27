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
  var notice = $('.notice:contains(text)');
  sb.flash_element(notice);
});

sb.flash_element = function(element) {
  if (element.length > 0) {
    //element.show().animate({height: element.outerHeight()}, 200);
    element.slideDown();
    window.setTimeout(function() {
      element.slideUp();
      element.clear();
    }, 5000);
  }

  element.find('.toast-item-close').live('click', function(){element.slideUp();});  
}

sb.showNoticeText = function(text) {
    var notice = $('.notice').text(text);
    sb.flash_element(notice);
}