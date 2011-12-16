$(document).ready(function() {
  $('h4.hideform').click(function() {
    $(this).next('form').toggle();
  });
  $('h4.hideform').click();

  if ($('div.attachments h4.more').length) {
    $('div.attachments h4.more').html('<a href="#">More...</a>');
    $('div.attachments ul.task-attachments').hide();
    $('div.attachments h4.more a').toggle(function() {
      $(this).text('Less...');
      $('div.attachments ul.task-attachments').show();
    }, function() {
      $(this).text('More...');
      $('div.attachments ul.task-attachments').hide();
    });
  }

  $(window).resize(function() {scaleToViewport();});
  scaleToViewport();
});

function scaleToViewport() {
  height = $(window).height() - 300;
  $('#tasks .panel > .content').css('height', height + 'px');
}

