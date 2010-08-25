/**
 * @file
 * Generic delete link popup script.
 *
 * @author Kale Worsley kale@egressive.com
 */
$(document).ready(function() {
  $('.delete > a, a.delete').each(function() {
    deleteLink($(this));
  });
});

function deleteLink(link) {
  link.click(function() {
    var href = $(this).attr('href');

    $('<div id="popup" />').load(href + ' #content', function() {
        ajaxifyForm($('#popup form'), function() {
          var controller = href.split('/')[1];
          var id = href.split('/')[2];
          $('#' + controller.substr(0, controller.length-1) + '_' + id).slideUp(1000, function() {$(this).remove();});
          $('#popup').dialog('close');
  	  $('#popup').remove();
          });
        $('#popup a.cancel').click(function() {
	  $('#popup').dialog('close');
	  $('#popup').remove();
          return false;
        });
      }).dialog({
      'modal': true,
       close: function() {$(this).remove()}
    });

    return false;
    });

}