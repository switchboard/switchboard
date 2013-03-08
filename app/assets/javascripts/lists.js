$(function() {
  $('.adminToggle').change( function() {
    var value = this.getAttribute("value");
    var list_id = this.getAttribute("list_id");
    $(this).siblings('img').show()
      $.ajax({
          url: '/lists/' + list_id + '/toggle_admin',
          data: 'list_member_id=' + value,
          success: admin_toggle_ok
      });
  });

  $('.spinner').hide()

});

var admin_toggle_ok = function(data, status, jqxhr) {
    $(".spinner").hide()
    Switchboard.showNoticeText("List admins updated.")
}
