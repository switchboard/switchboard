$(function() {
  // toggle admin
  $('.admin-checkbox').change(function() {
    var list_id = $(this).parents('ul').data('list_id'),
        member_id = $(this).parents('li').data('member_id');

    var data = {
      list_member_id: member_id,
      list_id: list_id
    };

    var $spinner = $('#spinner_' + member_id);

    $spinner.show();
    $.post('/lists/toggle_admin', data).
      fail(function() {
        alert('Error updating user');
      }).
      always(function() {
        $spinner.hide();
      });
  });
});
