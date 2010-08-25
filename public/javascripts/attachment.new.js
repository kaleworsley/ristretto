$(document).ready(function() {
  $('#attachments div:first input').after('<span class="delete"><a class="delete" href="#"><img src="/images/delete.png" alt="Delete"></a></span>');
  $('#attachments').after('<a href="#" class="add">Add another</a>');
  $('a.add').click(function() {
    var clone = $('#attachments div:first').clone();
    clone.html(clone.html());
    clone.hide();
    clone.appendTo('#attachments');
    clone.slideDown(500);
    return false;
  });
  
  $('#attachments div span.delete a').live('click', function() {
    if ($('#attachments').children().length == 1) {
      $(this).parents('.form-item').html($(this).parents('.form-item').html());
    }
    else {
	$(this).parents('.form-item').slideUp(500, function() { $(this).remove(); });
    }
    return false;
    });
});
