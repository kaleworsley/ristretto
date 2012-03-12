
$(function() {
  $('.dashboard-panels').sortable({
    forceHelperSize: true,
    handle: 'a',
    forcePlaceholderSize: true,	
  	axis: 'y',
  	stop: function(event, ui) {	
	  	updateOrder();
	  }
  });
  $('.dashboard-panels label input').change(function() {
   	updateOrder();
  });
});

function updateOrder() {
  $('.dashboard-panels label input').each(function(i) {
    if ($(this).is(':checked')) {
  	  $(this).val(i);
  	}
  	else {
  	  $(this).val(false);
  	}
  });
}
