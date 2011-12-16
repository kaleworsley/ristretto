$(document).ready(function() {
  //Grab the task id from the form 'action'
  var task_id = $('#new_comment').attr('action').split('/')[2];

  $('#comment_body').keyup(function() {
    var val = $(this).val();
    //Save cookie on keyup
    createCookie('commentBody'+task_id, val, 365);
  });

  $('#new_comment').submit(function() {
    //Remove cookie on submit
    removeCookie('commentBody'+task_id);
  });

  // Onload, if cooment body is blank, and the cookie isn't empty, fill the textarea
  if (readCookie('commentBody'+task_id) != null) {
    $('#comment_body').val(readCookie('commentBody'+task_id));
  }

});