Switchboard.close_alert = function() {
  var alert = $('.alert');
  alert.slideUp();
}

$(function () {
  var alert = $('.alert, .notice:contains(text)');
  Switchboard.flash_element(alert);
});

Switchboard.flash_element = function(element) {
  if (element.length > 0) {
    element.slideDown();
    window.setTimeout(function() {
      element.slideUp();
      element.remove();
    }, 5000);
    element.on('click', function(e) {$(e.target).slideUp(); })
  }
}

Switchboard.showNoticeText = function(text) {
    var notice = $('.notice').text(text);
    Switchboard.flash_element(notice);
}