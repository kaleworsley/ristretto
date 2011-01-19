$(document).ready(function() {
  $('#timeslice_task_id').mcDropdown("#task_mc_dropdown");

  if ($("input[type=hidden][name='timeslice[task_id]']").length > 0) {
    var task_id = $("input[type=hidden][name='timeslice[task_id]']").val();
  }
  else {
    var task_id = '';
  }
  timeentry_attrs = {
    show24Hours: true,
    timeSteps: [1,TIMESLICE_GRANULARITY,0],
    spinnerImage: '',
    initialField: 1,
  };

  finished_timeentry_attrs = {
    beforeShow: limitRange
  };

  finished_timeentry_attrs = {
    beforeShow: limitRange
  };
  $('#new_timeslice').attr('autocomplete', 'off');
  $('#timeslice_started_time').timeEntry(timeentry_attrs);
  $('#timeslice_started_time').change(function() {
    $('#timeslice_finished_time').timeEntry('change', {
      minTime: $(this).timeEntry('getTime')
    });
  });
  $('#timeslice_finished_time').timeEntry(timeentry_attrs);
  $('#timeslice_finished_time').timeEntry('change', finished_timeentry_attrs);
  $('#timeslice_description').keyup(function() {
    var val = $(this).val();
    createCookie('timesliceDescription:'+task_id, val, 365);
  });

  $('#task_autocomplete').keyup(function() {
    var val = $(this).val();
    createCookie('timesliceTaskAutocomplete', val, 365);
  });

  $('#timeslice_started_time').change(function() {
    var val = $(this).val();
    createCookie('timesliceStarted:'+task_id, val, 365);
  });

  $('#timeslice_finished_time').change(function() {
    var val = $(this).val();
    createCookie('timesliceFinished:'+task_id, val, 365);
  });

  $('#timeslice_started_4i, #timeslice_started_5i').change(function() {
    var val = $('#timeslice_started_4i').val() + ':' + $('#timeslice_started_5i').val();
    createCookie('timesliceStarted:'+task_id, val, 365);
  });

  $('#timeslice_finished_4i, #timeslice_finished_5i').change(function() {
    var val = $('#timeslice_finished_4i').val() + ':' + $('#timeslice_finished_5i').val();
    createCookie('timesliceFinished:'+task_id, val, 365);
  });

  $('#task_autocomplete').keyup(function() {
    var val = $(this).val();
    createCookie('timesliceTaskAutocomplete', val, 365);
  });

  $('#timeslice_task_id').change(function() {
    var val = $(this).val();
    createCookie('timesliceTaskId', val, 365);
  });

  if (readCookie('timesliceTaskAutocomplete') != null) {
    $('#task_autocomplete').val(readCookie('timesliceTaskAutocomplete'));
    $('#task_autocomplete').keyup();
    $('#task_autocomplete').focusout();
  }

  if (readCookie('timesliceTaskId') != null) {
    $('body.timeslices-timesheet #timeslice_task_id').val(readCookie('timesliceTaskId'));
    $('body.timeslices-timesheet #timeslice_task_id').change();
    $('body.timeslices-timesheet #timeslice_task_id').focusout();
    //$('#timeslice_task_id option[value=' + readCookie('timesliceTaskId') + ']').attr('selected', 'selected');
  }

  if (readCookie('timesliceDescription:'+task_id) != null) {
    $('#timeslice_description').val(readCookie('timesliceDescription:'+task_id));
    $('#timeslice_description').focus();
  }

  if (readCookie('timesliceStarted:'+task_id) != null) {
    $('#timeslice_started_time').val(readCookie('timesliceStarted:'+task_id));
    $('#timeslice_started_4i').val(readCookie('timesliceStarted:'+task_id).split(':')[0]);
    $('#timeslice_started_5i').val(readCookie('timesliceStarted:'+task_id).split(':')[1]);
  }

  if (readCookie('timesliceFinished:'+task_id) != null) {
    $('#timeslice_finished_time').val(readCookie('timesliceFinished:'+task_id));
    $('#timeslice_finished_4i').val(readCookie('timesliceFinished:'+task_id).split(':')[0]);
    $('#timeslice_finished_5i').val(readCookie('timesliceFinished:'+task_id).split(':')[1]);
  }

  $('body.tasks-show .time-details div.started').prepend('<span class="clock-now"><a href="#" title="Set the started time to now"><img src="/images/clock.png" alt="Clock"></a></span>');
  $('body.tasks-show .time-details div.finished').prepend('<span class="clock-now"><a href="#" title="Set the finished time to now"><img src="/images/clock.png" alt="Clock"></a></span>');

  $('body.tasks-show .time-details div.started span.clock-now a').click(function() {
	var now = new Date();
	var time = pad0(now.getHours()) + ':' + pad0(now.getMinutes());
	$('#timeslice_started_time').val(time);
  });

  $('body.tasks-show .time-details div.finished span.clock-now a').click(function() {
	var now = new Date();
	var time = pad0(now.getHours()) + ':' + pad0(now.getMinutes());
	$('#timeslice_finished_time').val(time);
  });


  $('body.tasks-show .time-details').append('<span class="clock start"><a href="#"><img src="/images/clock-start.png" alt="Clock"></a></span>');
  $('body.tasks-show .time-details').find('.clock.start a').live('click', function() {
    var title = $('#content h2.title:first').text();
    var now = new Date();
    var time = $('#timeslice_started_time').val();
    flashNotice('Starting timer for "' + title + '"...');
    createCookie('timesliceStarted:'+task_id, time, 365);
    removeCookie('timesliceFinished:'+task_id);
    createCookie('timesliceTimer:'+task_id, true, 365);
    $(this).find('img').attr('src', '/images/clock-stop.png');
    $(this).parent().toggleClass('start');
    $(this).parent().toggleClass('stop');
    updateFinished = true;
    updateFinishedTime();
    $('#timeslice_started_time').attr('readonly', 'readonly');
    $('#timeslice_finished_time').attr('readonly', 'readonly');
    return false;
  });

  $('body.tasks-show .time-details').find('.clock.stop a').live('click', function() {
    var title = $('#content h2.title:first').text();
    var now = new Date();
    var time = pad0(now.getHours()) + ':' + pad0(now.getMinutes());
    flashNotice('Stopping timer for "' + title + '"...');
    createCookie('timesliceFinished:'+task_id, time, 365);
    removeCookie('timesliceTimer:'+task_id);
    $(this).find('img').attr('src', '/images/clock-start.png');
    $(this).parent().toggleClass('start');
    $(this).parent().toggleClass('stop');
    updateFinished = false;
    $('#timeslice_started_time').removeAttr('readonly');
    $('#timeslice_finished_time').removeAttr('readonly');
    return false;
  });


  if (readCookie('timesliceTimer:'+task_id)) {
    $('body.tasks-show .time-details').find('.clock a img').attr('src', '/images/clock-stop.png');
    $('body.tasks-show .time-details').find('.clock').toggleClass('start');
    $('body.tasks-show .time-details').find('.clock').toggleClass('stop');
    $('#timeslice_started_time').attr('readonly', 'readonly');
    $('#timeslice_finished_time').attr('readonly', 'readonly');
    updateFinished = true;
    updateFinishedTime();
  }
});

/* Limit relevant time entry max + min based on value of the other */
function limitRange(input) {
  return {
    minTime: (input.id == 'timeslice_finished_time' ?
              $('#timeslice_started_time').timeEntry('getTime') : null),
    maxTime: (input.id == 'timeslice_started_time' ?
              $('#timeslice_finished_time').timeEntry('getTime') : null)
  }
}

function updateFinishedTime() {
  if (updateFinished) {
    var now = new Date();
    var time = pad0(now.getHours()) + ':' + pad0(now.getMinutes()) + ':' + pad0(now.getSeconds())
    $('#timeslice_finished_time').val(time);
    setTimeout("updateFinishedTime()", 1000);
  }
}
