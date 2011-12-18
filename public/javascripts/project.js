/*
$(function() {
	$('.project-tasks tbody tr:last-child input').live('focus', function() {
	  	new_task_row();
	});
});

function new_task_row() {
  var count = $('.project-tasks tbody').children().length;	
  var row = $('.project-tasks tbody').children().last().html();
  var new_row = row.replace(/_\d+_/g, "_"+count+"_").replace(/\[\d+\]/g, "["+count+"]");
  $('.project-tasks tbody').append('<tr>' + new_row + '</tr>');
}
*/

$(function() {
  $('.tasks .project-tasks tbody').sortable({
    forceHelperSize: true,
    forcePlaceholderSize: true,	
  	axis: 'y',
	  stop: function(event, ui) {	
	  	$('.tasks .project-tasks tbody tr').each(function(i) {
	  		$('input.weight', this).val(i);
	    });
	  }
  });
});