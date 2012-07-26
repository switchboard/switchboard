$(function() {
  $('.delete_membership').on('ajax:success', function() {
    $(this).closest('ul').fadeOut();
  });
});
