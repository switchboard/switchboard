$(function($) {
    $("#list_name").change(function() {
 	alert("ok, name is changed");	
        $.ajax({url: '/admin/check_list_availability',
        	data: 'name=' + this.value,
		      "success": switchboard.check_list_name_ok 
        	})
    });
});

switchboard = {}

switchboard.check_list_name_ok = function(data, status, jqxhr) {
  console.log("received list name availability response");
  console.log("data: %o", data);

  $("#availability").empty().append( data.message );
  if (data.available) {
    $("#new_list_submit").attr("disabled", false);
  } else {
    $("#new_list_submit").attr("disabled", true);
  }
}