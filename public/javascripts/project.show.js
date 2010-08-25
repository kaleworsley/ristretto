$(document).ready(function() {
  $('h4.hideform').click(function() {
    $(this).next('form').toggle();
  });
  $('h4.hideform').click();
});
