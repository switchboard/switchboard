sb.close_alert = function() {
  var alert = $('.alert');
  alert.slideUp();
}

$(function () {
  var alert = $('.alert, .notice:contains(text)');
  sb.flash_element(alert);
});

sb.flash_element = function(element) {
  if (element.length > 0) {
    element.slideDown();
    window.setTimeout(function() {
      element.slideUp();
      element.remove();
    }, 5000);
    element.on('click', function(e) {$(e.target).slideUp(); })
  }
}

sb.showNoticeText = function(text) {
    var notice = $('.notice').text(text);
    sb.flash_element(notice);
}