$(document).ready(function() {
  $('#update-ar').accordion({
    autoHeight: false,
    header: 'h3',
    collapsible: true,
    active: false
  });

  $('.customer .projects').accordion({
    autoHeight: false,
    header: 'h4',
    collapsible: true,
    active: false
  });

  $('table.update-ar-table tbody tr td:not(.form)').click(function() {
    var text = [];
    var hours1 = $(this).parent().find('td.hours:first').text();
    var hours2 = $(this).parent().find('td.hours:last').text();
    $(this).parent().find('td:not(.form)').each(function() {
      text.push($(this).text());
    });
    var field = '<input class="line-item" type="textfield" style="width: 100%" value="'+ text.join(' - ') +'" />';
    $(this).parent().html('<td class="form">' +  $(this).parent().find('.form').html() + '</td><td colspan="4">' + field + '</td><td class="hours"><input type="textfield" value="' + hours1 + '" style="width: 40px;" /><td class="hours"><input type="textfield" value="' + hours2 + '" style="width: 40px;" /></div>').find('input.line-item').focus()[0].select();
  });
});