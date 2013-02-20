$(function() {
  // check availability of list name
  $("#list_name").change(function() {
    $.ajax({
      url: '/admin/check_list_availability',
      data: 'name=' + this.value,
      success: check_list_name_ok
      });
  });


  // toggle welcome message textarea
  $('#list_use_welcome_message').change(function() {
    $('#welcome_message').toggle();
  });

  // count message chars
  $('#welcome_message').keyup(function() {
    countMessageBody(this);
  });

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

var domLog = function($obj){ console.log.apply(console,$obj); }

var admin_toggle_ok = function(data, status, jqxhr) {
    console.log("received admin toggle response");
    console.log("data: %o", data)
    $(".spinner").hide()
    sb.showNoticeText("List admins updated.")
}

var check_list_name_ok = function(data, status, jqxhr) {
  console.log("received list name availability response");
  console.log("data: %o", data);

  $("#availability").empty().append( data.message );
  if (data.available) {
    $("#new_list_submit").attr("disabled", false);
  } else {
    $("#new_list_submit").attr("disabled", true);
  }
}
