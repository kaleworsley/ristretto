$(function() {
  $('#project_kind').change(function() {
    if ($(this).val() == 'support') {
      $('.tasks').hide();
      $('#project_fixed_price').parents('.clearfix').hide();
    }
    else {
      $('.tasks').show();
      $('#project_fixed_price').parents('.clearfix').show();
    }
  });
  $('#project_kind').change();
  $('.tasks .project-tasks tbody').sortable({
    items: 'tr:not(.add)',
    forceHelperSize: true,
    handle: 'a',
    forcePlaceholderSize: true,	
  	axis: 'y',
	  stop: function(event, ui) {	
	  	updateOrder();
	  }
  });
  $(".btn.add.icon").click(function(){
		updateOrder();
  });
});

function updateOrder() {
  $('.tasks .project-tasks tbody tr').each(function(i) {
    $('input.weight', this).val(i);
  });
}
