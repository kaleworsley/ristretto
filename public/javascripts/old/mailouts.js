$(document).ready(function(){
  $("select.multiple").multiselect({
    sortable: false, dividerLocation: 0.5
  });

  $('#user_select_container').toggle(!$('#send_to_all_users').is(':checked'));

  $('#send_to_all_users').click(function() {
    $('#user_select_container').toggle(!$(this).is(':checked'));
  });
});
