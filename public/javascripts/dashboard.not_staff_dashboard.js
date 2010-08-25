$(document).ready(function() {
  $('div.expand-collapse').each(function() {
    var parent = $(this).parents('div.task, div.project');
    $(this).prepend('<a href=""></a>');
    parent.find('.content').hide();
  });
  
  //Return false on collapse/expand and handle anchors
  $('.expand-collapse a').click(function() {
    var parent = $(this).parents('div.task, div.project');
    $(this).parent().toggleClass('expand').toggleClass('collapse');
    parent.find('.content').toggle();
    parent.toggleClass('expanded');
    return false;
  });

  $('#tasks-to-action form').each(function() {
    var task = $(this).parents('div.task');
    var form = $(this);
    var title = task.find('span.title a').text();
    form.submit(function (){
      if (form.hasClass('reject')) {
        var go = confirm('Are you sure you want to reject "' + title + '"?');
        var state = "rejected";
      }
      else {
        var go = confirm('Are you sure you want to accept "' + title + '"?');
        var state = "accepted"
      }
      if (go) {
        $.ajax({
          type: form.attr('method'),
          url: form.attr('action'),
          data: form.serialize(),
          success: function (data) {
            form[0].reset();
            flashNotice('"' + title + '" has been ' + state + '.');
            flashMessage();
            $.throbberHide();
            task.slideUp();
          },
          dataType: "json"
        });
      }
      return false;
    });
    $('input[type=submit]', form).click(function() {
      $(this).parents('form').submit();
      return false;
    });
  });  
});