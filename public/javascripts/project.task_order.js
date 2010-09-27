$(document).ready(function() {
  taskOrder();
  // Ajaxifies the task order form
  ajaxifyForm($('#task_order_form'), function(data) {
    //task variable comes from the request
    /*
    // TODO: sort this out
    $.each(tasks, function(index, task) {
      $('#task_states_' + task.task.id).val(task.task.state);
      $('#task_orders_' + task.task.id).val(task.task.order);
    });
    */
  });
});

function taskOrder() {
  //Add blank anchor to the handles
  $('div.task_order div.tasks div.handle').each(function() {
    $(this).prepend('<a href="#"></a>');
    $(this).find('a').click(function() { return false; });
  });
  //Add blank anchor to the options
  $('div.task_order div.tasks div.options').each(function() {
    $(this).prepend('<a href=""></a>');
    $('a', this).bt({
      trigger: 'click',
      fill: '#F3F3F3',
      closeWhenOthersOpen: true,
      cornerRadius: 4,
      strokeWidth: 1,
      strokeStyle: '#939393',
      shadow: true,
      shadowOffsetX: 0,
      shadowOffsetY: 0,
      shadowBlur: 3,
      shadowColor: '#888',
      shadowOverlap: false,
      contentSelector: "$(this).parents('.task').find('.edit-links')",
      noShadowOpts: {strokeStyle: '#999', strokeWidth: 2},
      shrinkToFit: true,
      cssStyles: {
	    color: '#000'
      },
      postShow: function(box) {

	    var task_id = $(box).find('.task_id').text();
	    var title = $('div#task-'+ task_id).find('.title').text();
	    $(box).find('.clock.start a').live('click', function() {

	      var now = new Date();
	      var time = pad0(now.getHours()) + ':' + pad0(now.getMinutes());
	      flashNotice('Starting timer for "' + title + '"...');
	      createCookie('timesliceStarted:'+task_id, time, 365);
	      removeCookie('timesliceFinished:'+task_id);
	      createCookie('timesliceTimer:'+task_id, true, 365);
	      $(this).find('img').attr('src', '/images/clock-stop.png');
	      $(this).parent().toggleClass('start');
	      $(this).parent().toggleClass('stop');
	      $(this).find('span.label').text('Stop Timer');

	      return false;
	    });

	    $(box).find('.clock.stop a').live('click', function() {

	      var now = new Date();
	      var time = pad0(now.getHours()) + ':' + pad0(now.getMinutes());
	      flashNotice('Stopping timer for "' + title + '"...');
	      createCookie('timesliceFinished:'+task_id, time, 365);
	      removeCookie('timesliceTimer:'+task_id);
	      $(this).find('img').attr('src', '/images/clock-start.png');
	      $(this).parent().toggleClass('start');
	      $(this).parent().toggleClass('stop');
	      $(this).find('span.label').text('Start Timer');

	      return false;
	    });

	    if (readCookie('timesliceTimer:'+task_id)) {
	      $(box).find('.clock a img').attr('src', '/images/clock-stop.png');
	      $(box).find('.clock').toggleClass('start');
	      $(box).find('.clock').toggleClass('stop');
	      $(box).find('.clock span.label').text('Stop Timer');
	    }
      }
    }).click(function() { return false; });
  });
  //Hide submit button
  $('#task_order_form input[value=Update order]').hide();
  //Return false on collapse/expand and handle anchors
  $('.expand-collapse a, .handle a').click(function() { return false; });

  if (!IS_STAFF) {
    $('.handle').hide();
  }
  //Makes the tasks sortable
  if (IS_STAFF) {
    $('div.task_order > div.tasks').sortable({
      'axis': 'y',
      'containment': 'parent',
      'handle': '.handle',
      'cursor': 'move',
      'delay': 250,
      'placeholder': 'ui-state-highlight',
      stop: function(event, ui) {
	    updateTaskOrder();
      }
    }).disableSelection();
  }

  if (IS_STAFF) {
    $('.task').each(function() {
      $('ul.edit-links', this).append('<li><span class="clock start"><a href="#"><img src="/images/clock-start.png" alt="Clock"> <span class="label">Start Timer</span></a></span></li>');
      var task_id = $(this).parents('div.task').find('.handle .task-id').val();
      $(this).find('.clock.start a').live('click', function() {
	    var title = $(this).parents('div.task').find('.title').text();
	    var now = new Date();
	    var time = pad0(now.getHours()) + ':' + pad0(now.getMinutes());
	    flashNotice('Starting timer for "' + title + '"...');
	    createCookie('timesliceStarted:'+task_id, time, 365);
	    removeCookie('timesliceFinished:'+task_id);
	    createCookie('timesliceTimer:'+task_id, true, 365);
	    $(this).find('img').attr('src', '/images/clock-stop.png');
	    $(this).parent().toggleClass('start');
	    $(this).parent().toggleClass('stop');
	    return false;
      });

      $(this).find('.clock.stop a').live('click', function() {
	    var title = $(this).parents('div.task').find('.title').text();
	    var now = new Date();
	    var time = pad0(now.getHours()) + ':' + pad0(now.getMinutes());
	    flashNotice('Stopping timer for "' + title + '"...');
	    createCookie('timesliceFinished:'+task_id, time, 365);
	    removeCookie('timesliceTimer:'+task_id);
	    $(this).find('img').attr('src', '/images/clock-start.png');
	    $(this).parent().toggleClass('start');
	    $(this).parent().toggleClass('stop');
	    return false;
      });

      if (readCookie('timesliceTimer:'+task_id)) {
	    $(this).find('.clock a img').attr('src', '/images/clock-stop.png');
	    $(this).find('.clock').toggleClass('start');
	    $(this).find('.clock').toggleClass('stop');
      }
    });

    updateClockTitle();
  }

  if (IS_STAFF) {
    $('div.task_order div.task:not(.edit-active) span.cypher').live('click', function() {
      var self = $(this);
      $(this).parents('div.task').addClass('edit-active');
      var task_id = $(this).parents('div.task').find('.handle .task-id').val();
      $(this).load('/tasks/' + task_id + '/edit #task_assigned_to_id', function() {
        $(this).find('select').bind('change blur', function() {
          $.post('/tasks/' + task_id +'.js', $(this).serialize()+'&_method=put', function(data) {
            self.html('(' + data.task.cypher + ')');
	        self.attr('title', data.task.assigned_to);
	        self.attr('bt-xtitle', data.task.assigned_to);
          }, 'json');
        });
      });
    });
  }

  $('div.task_order div.task:not(.edit-active) div.state-button a').live('click', function(event) {
    $(this).parents('div.state-buttons').hide();
    var task_id = $(this).parents('div.task').find('.handle .task-id').val();
    var next_state = $(this).attr('rel');
    $(this).parents('div.task').addClass('edit-active');
    var weight = '';
    switch (next_state) {
    case 'started':
	  $(this).parents('div.task').slideUp('fast', function() {
	    $(this).appendTo('#task_order_doing div.tasks').slideDown('fast', function() {});
      });
      if (IS_STAFF) {
        weight = '&task[weight]=' + ($('#task_order_doing div.tasks').children().length+2);
      }
	  //doing
	  break;
    case 'rejected':
	  $(this).parents('div.task').slideUp('fast', function() {
	    $(this).prependTo('#task_order_todo div.tasks').slideDown('fast', function() {});
      });
      if (IS_STAFF) {
        weight = '&task[weight]=-' + ($(this).prependTo('#task_order_todo div.tasks').children().length+2);
      }
	  //todo
	  break;
    case 'accepted':
	  $(this).parents('div.task').slideUp('fast', function() {
	    $(this).prependTo('#task_order_done div.tasks').slideDown('fast', function() {});
	  });
      if (IS_STAFF) {
        weight = '&task[weight]=-' + ($('#task_order_done div.tasks').children().length+2);
      }
	  //done
	  break;
    }
    $.post('/tasks/' + task_id, '_method=put&task[state]=' + next_state + weight, function(data) {
      var buttons = '';
      $.each(data.task.next_states, function(i, state) {
        var state_title = state.charAt(0).toUpperCase() + state.slice(1);
        buttons +='<div title="' + state_title + '" class="state-button state ' + state + '"><a href="#" rel="' + state + '">' + state_title.replace(/ed$/,'') + '</a></div>'
      })
      $('div#task-' + task_id + ' div.state-buttons').html(buttons);
      $('div#task-' + task_id + ' div.state-buttons').show();
      $('div#task-' + task_id).removeClass('edit-active');
    }, 'json');
    
    return false;
  });
}

function updateClockTitle() {
  $('.clock.stop').each(function() {
    var task_id = $(this).parents('div.task').find('.handle .task-id').val();
    var started = readCookie('timesliceStarted:'+task_id);
    var now = new Date();
    var time = pad0(now.getHours()) + ':' + pad0(now.getMinutes()) + ':' + pad0(now.getSeconds());
    var title = started + ' - ' + time;
    $(this).find('img').attr('title', title);
    $(this).find('.clock span.label').text('Stop Timer');
  });
  setTimeout("updateClockTitle()", 1000);
}

function updateTaskOrder() {
  //Update the orders of the tasks
  $('.order input[type=hidden]').each(function(i, element) {
    $(this).val(i)
  });
  //Save changes (ajax)
  $('#task_order_form').submit();
}