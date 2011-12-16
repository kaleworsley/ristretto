$(document).ready(function() {
  $('#project-list').each(function() {
    //Add search input field to the heading tag
    $(this).find('h3:first').append($('<input />', {
      'type': 'text',
      'class': 'search'
    }));
  });
  $('input.search', this).css('opacity', '0.6');
  $('input.search', this).focus();

  // Redues a list based on the value of a textfield
  $('input.search', this).keyup(function() {
    var search = $(this).val().toLowerCase();
    var panel = $('#project-list');
    if (search != '') {
      panel.addClass('searching');
      panel.find('.project').each(function() {
        if (searchAll(search, $(this).text().toLowerCase()) > -1) {
          $(this).addClass('match');
        }
        else {
          $(this).removeClass('match');
        }
      });
    }
    else {
      panel.removeClass('searching');
      panel.find('.project').removeClass('match');
    }
  });
});