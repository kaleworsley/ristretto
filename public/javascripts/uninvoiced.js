$(function() {
  $("#issue_date, #due_date").datepicker({dateFormat: 'yy-mm-dd'});
  
  $('#invoice tbody input').change(function() { update_total_hours(); });
  update_total_hours();
});

function update_total_hours() {
  var total = 0.0;
  $('#invoice tbody tr:not(.heading)').each(function() {
    var hours = $('td.hours input', this);
    var include = $('td.include input[type=checkbox]', this);
    console.debug(include);
    if (include.is(':checked')) {
      total = parseFloat(total)+parseFloat(hours.val());
    }
  });
 
  $('td.total-hours').text(total.toFixed(2));
  
  return total
}
