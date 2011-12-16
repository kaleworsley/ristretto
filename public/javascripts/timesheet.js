$(function() {
  $('#timesheet-calendar').fullCalendar({
    events: '/timesheet',
    firstHour: 9,
    allDaySlot: false,
    defaultView: 'agendaDay',
    slotMinutes: 15,
    editable: true,
    header: false,
    theme: false,
    height: 400,
    selectable: true,
    selectHelper: true,
    select: function(start, end, allDay) {
      start = Math.round(start.getTime() / 1000);
      end = Math.round(end.getTime() / 1000);

      $('<div id="popup" />').load('/timeslices/new?start=' + start + '&end=' + end + ' #content', function() {
        //$('#timeslice_task_id').mcDropdown("#task_mc_dropdown");
        ajaxifyForm($('#popup form'), function() {
          $('#popup').dialog('close');
	        $('#popup').remove();
          $('ul#task_mc_dropdown').remove();
          $('#timesheet-calendar').fullCalendar('refetchEvents');
          // $(this).fullCalendar('unselect');
        });
      }).dialog({
        'modal': true,
        width: 980,
        height: 370,
	draggable: false,
        resizable: false,
        close: function() {
          $(this).remove();
          //$('ul#task_mc_dropdown').remove();
        }
      });
    },
    eventDrop: function(event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view) {
      var self = $(this);
      saveTimeslice(event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view, self);
    },
    eventResize: function(event, dayDelta, minuteDelta, revertFunc, jsEvent, ui, view) {
      var self = $(this);
      saveTimeslice(event, dayDelta, minuteDelta, false, revertFunc, jsEvent, ui, view, self);
    },
    eventRender: function(event, element) {
      element.find('.fc-event-title').append(' - ' + event.description);
    },
    eventClick: function( event, jsEvent, view) {
     // $('<div id="popup" />').load('/timeslices/' + event.id + '/edit #content')
    	
      $('<div id="popup" />').load('/timeslices/' + event.id + '/edit #content', function() {
        //$('#timeslice_task_id').mcDropdown("#task_mc_dropdown");
        ajaxifyForm($('#popup form'), function() {
          $('#popup').dialog('close');
          $('#popup').remove();
          //$('ul#task_mc_dropdown').remove();
          $('#timesheet-calendar').fullCalendar('refetchEvents');
        });
      }).dialog({
        'modal': true,
        width: 980,
        height: 370,
	draggable: false,
        resizable: false,
        close: function() {
	  $(this).remove();
          $('ul#task_mc_dropdown').remove();
        }
      });
      
    },
  });	
});


function saveTimeslice(event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view, self) {
  var object = {};
  object['authenticity_token'] = encodeURIComponent(AUTH_TOKEN);
  object['_method'] = 'put';
  object['timeslice[started]'] = event.start.toString();
  object['timeslice[finished]'] = event.end.toString();
  $.post('/timeslices/' + event.id + '.js', object, null, 'script');
  $('body').ajaxError(function(e, xhr, settings, exception) {
    if (xhr.status == '422') {
      revertFunc();
    }
  });
}
