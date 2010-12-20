$(document).ready(function() {
  var path = location.pathname.split('/');
  var date = path[path.length-1].split('-');
  var newdate = new Date();

  $('#timesheet').fullCalendar({
    year: (date[0].length == 4) ? date[0] : newdate.getFullYear(),
    month: (date[1] && date[1].length == 2) ? date[1]-1 : newdate.getMonth(),
    date: (date[2] && date[2].length == 2) ? date[2] : newdate.getDate(),
    theme: true,
    height: 555,
    viewDisplay: function(view) {
      toggleNav(view);
      createCookie('timesheetCalendarView', view.name, 365);
    },
    header: {
      //left: 'prev,next',
      left: '',
      right: '',
      center: 'title',
      right: 'month,agendaWeek,agendaDay, today'
    },
    selectable: true,
    selectHelper: true,
    select: function(start, end, allDay) {
      start = Math.round(start.getTime() / 1000);
      end = Math.round(end.getTime() / 1000);
      console.debug(start);

      $('<div id="popup" />').load('/timeslices/new?start=' + start + '&end=' + end + ' #content', function() {
        ajaxifyForm($('#popup form'), function() {
          $('#popup').dialog('close');
	      $('#popup').remove();
          $('#timesheet').fullCalendar('refetchEvents');
          //$(this).fullCalendar('unselect');
        });
      }).dialog({
        'modal': true,
        maxWidth: $(document).width(),
        maxHeight: $(document).height(),
        minWidth: $(document).width() / 2,
        width: $(document).width() / 2,
        height: $(document).height() / 2,
        close: function() {$(this).remove()}
      });
    },
    firstHour: 9,
    allDaySlot: false,
    defaultView: readCookie('timesheetCalendarView') || 'agendaDay',
    slotMinutes: 15,
    editable: true,
    events: '/timesheet',
    eventDrop: function(event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view) {
      var self = $(this);
      saveTimeslice(event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view, self);
    },
    eventResize: function(event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view) {
      var self = $(this);
      saveTimeslice(event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view, self);
    },
    eventRender: function(event, element) {
      element.find('.fc-event-title').append(' - ' + event.description);
    },
    eventClick: function( event, jsEvent, view ) {
      $('<div id="popup" />').load('/timeslices/' + event.id + '/edit #content', function() {
        ajaxifyForm($('#popup form'), function() {
          $('#popup').dialog('close');
	      $('#popup').remove();
          $('#timesheet').fullCalendar('refetchEvents');
        });
      }).dialog({
        'modal': true,
        maxWidth: $(document).width(),
        maxHeight: $(document).height(),
        minWidth: $(document).width() / 2,
        width: $(document).width() / 2,
        height: $(document).height() / 2,
        close: function() {$(this).remove()}
      });
    },
    eventAfterRender: function( event, element, view ) {
	  /*
	      element.bt({
		      fill: '#F3F3F3',
			  cornerRadius: 4,
			  strokeWidth: 1,
			  strokeStyle: '#939393',
			  shadow: true,
			  shadowOffsetX: 0,
			  shadowOffsetY: 0,
			  shadowBlur: 3,
			  contentSelector:  "$(this).find('.fc-event-time').text() + '<br />' + $(this).find('.fc-event-title').text()",
			  shadowColor: '#888',
			  shadowOverlap: false,
			  noShadowOpts: {strokeStyle: '#999', strokeWidth: 2},
			  shrinkToFit: true,
			  cssStyles: {
			  color: '#000'
			      }

		  });
	  */
	}
  });

  $('#timesheet').before('<div class="toggle-calendar calendar"><a href="#">Calendar off</a></div>');

  $('#timesheet-table').hide();
  //$('.week-nav').hide();
  $('.toggle-calendar a').click(function() {
    $(this).parent().toggleClass('calendar');
    $(this).parent().toggleClass('timesheet');

    if ($(this).parent().hasClass('timesheet')) {
      createCookie('timesheetView', 'timesheet', 365);
      toggleNav({'name': 'agendaWeek'});
      $('#timesheet').hide();
      $('#timesheet-table').html('');
      $('#timesheet-table').show();
      $('#timesheet-table').addClass('loading');
      $('#timesheet-table').load(document.location + ' #timesheet-table', function() {
        $('#timesheet-table').removeClass('loading');
      });
      $(this).text('Calendar on');
    }

    if ($(this).parent().hasClass('calendar')) {
      createCookie('timesheetView', 'calendar', 365);
      toggleNav($('#timesheet').fullCalendar('getView'));
      $('#timesheet').show();
      $('#timesheet').fullCalendar('refetchEvents');
      $('#timesheet').fullCalendar('render');
      $('#timesheet-table').hide();
      $(this).text('Calendar off');
    }
    return false;
  });
  if (readCookie('timesheetView') == 'timesheet') {
    $('.toggle-calendar a').click();
    toggleNav($('#timesheet').fullCalendar('getView'));
  }

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
	  // TODO: Make this work
	  //revertFunc();
    }
  });
}

function toggleNav(view) {
  switch (view.name) {
  case 'agendaDay':
    $('.week-nav').hide();
    $('.month-nav').hide();
    $('.day-nav').show();
    break;
  case 'agendaWeek':
    $('.week-nav').show();
    $('.month-nav').hide();
    $('.day-nav').hide();
    break;
  case 'month':
    $('.week-nav').hide();
    $('.month-nav').show();
    $('.day-nav').hide();
    break;
  }
}