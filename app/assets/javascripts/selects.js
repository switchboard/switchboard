$(function() {
  $('#listSelect').change(function() {
    var id = $('#listSelect option:selected').val();

    if (id !== 0) {
      window.location.href = '/lists/' + id;
    }
  });
});
