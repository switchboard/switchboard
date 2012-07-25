$(function() {
  // count chars
  $('#message_body_textarea').keyup(function() {
    countMessageBody(this);
  });

  // send message
  $('#send-button').click(function() {
    var $spinner = $('#send_message_spinner');

    var list_id = $(this).data('list_id');
    var data = {
      list_id: $(this).data('list_id'),
      message_body: $('#message_body_textarea').val(),
      confirmed: false
    };

    $spinner.show();

    $.post('/send_message', data).
    success(function(response) {
      alert(response);
    }).
    always(function() {
      $('#send_message_spinner').hide();
    });
  });
});
