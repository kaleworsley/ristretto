$(function() {
  initTimesheetCalendar();
  /*
  $("#timesheet").bind('resize:stop', function() {
    $('#timesheet-calendar').fullCalendar('destroy');
    initTimesheetCalendar();
  });
  */
});

function initTimesheetCalendar() {
  $('#timesheet-calendar').fullCalendar({
    events: '/timesheet',
    firstHour: 9,
    allDaySlot: false,
    defaultView: ($('#timesheet-calendar').hasClass('large')) ? 'agendaWeek' : 'agendaDay',
    slotMinutes: 15,
    editable: true,
    header: false,
    theme: false,
    height: $("#timesheet .panel").height() || 700,
    selectable: true,
    selectHelper: true,
    select: function(start, end, allDay) {
      started = Math.round(start.getTime() / 1000);
      finished = Math.round(end.getTime() / 1000);

      $('<div id="popup" />').load('/timeslices/add?started=' + started + '&finished=' + finished + ' #content', function() {

      $('.tabs').tabs()

      $('#task_timeslice_timetrackable_object').chosen();
      $('#ticket_timeslice_timetrackable_object').chosen();
      $('#timeslice_timetrackable_object').chosen();
      $('#timeslice_task_id').chosen();

      $('#popup form').ajaxForm(function() {
        $('#popup').dialog('close');
       $('#popup').remove();
        $('#timesheet-calendar').fullCalendar('refetchEvents');
        $(this).fullCalendar('unselect');
      });
      
    }).dialog({
        modal: true,
        title: 'New Timeslice <em>' + start.toTimeString().slice(0, 5) + ' - ' + end.toTimeString().slice(0, 5) + '</em>',
        width: 980,
        height: $(window).height()/1.1,
	      draggable: false,
        resizable: false,
        close: function() {
          $(this).remove();
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
      $('<div id="popup" />').load('/timeslices/' + event.id + '/edit #content', function() {

        $('.tabs').tabs()

        $('#task_timeslice_timetrackable_object').chosen();
        $('#ticket_timeslice_timetrackable_object').chosen();
        $('#timeslice_timetrackable_object').chosen();
        $('#timeslice_task_id').chosen();

       $('#popup form').ajaxForm(function() {
          $('#popup').dialog('close');
          $('#popup').remove();
          $('#timesheet-calendar').fullCalendar('refetchEvents');
        });
      }).dialog({
        modal: true,
        title: "Editing <em>" + event.description + "</em>",
        width: 980,
        height: $(window).height()/1.1,
        draggable: false,
        resizable: false,
        close: function() {
	        $(this).remove();
        }
      });      
    },
  });
}


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
