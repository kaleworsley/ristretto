$(document).ready(function() {
  $('h4.hideform').click(function() {
    $(this).next('form').toggle();
  });
  $('h4.hideform').click();

  $(window).resize(function() {scaleToViewport();});
  scaleToViewport();
});

function scaleToViewport() {
  height = $(window).height() - 300;
  $('.panel > .content').css('height', height + 'px');
}

