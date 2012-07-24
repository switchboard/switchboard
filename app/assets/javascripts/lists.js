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

});

var countMessageBody = function(textarea) {

  charcount = textarea.value.length;

  if (charcount > 140) {
    textarea.value = textarea.value.substring(0, 140);
  } else {
    $('#character_count').text(charcount + " / 140");
  }
};

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
