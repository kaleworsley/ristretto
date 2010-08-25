$(document).ready(function() {
  taskOrder();
  // Ajaxifies the task order form
  ajaxifyForm($('#task_order_form'), function(data) {
    //task variable comes from the request
    $.each(tasks, function(index, task) {
      $('#task_states_' + task.task.id).val(task.task.state);
      $('#task_orders_' + task.task.id).val(task.task.order);
      });
    });
});

function taskOrder() {
  //Add blank anchor to the handles
  $('div.task_order div.tasks div.handle').each(function() {
    $(this).prepend('<a href=""></a>');
  });
  //Add blank anchor to the expand and collapse elements
  $('div.expand-collapse').each(function() {
    $(this).prepend('<a href=""></a>');
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
      'handle': '.handle',
      'cursor': 'move',
      'connectWith': 'div.task_order div.tasks',
      'delay': 250,
      'placeholder': 'ui-state-highlight',
      receive: function(event, ui) {
        removeTaskState(ui.item);
        // Changes the hidden 'state' field, 'current-state' div, and classes to
        // the new values
        switch (ui.item.parents('div.task_order').attr('id')) {
          case 'task_order_todo':
            ui.item.addClass('rejected');
            ui.item.find('.state input[type=hidden]').val('rejected');
            ui.item.find('.current-state').addClass('rejected').attr('title', 'Rejected').attr('bt-xtitle', 'Rejected').html('R');
          break;
          case 'task_order_doing':
            ui.item.addClass('started');
            ui.item.find('.state input[type=hidden]').val('started');
            ui.item.find('.current-state').addClass('started').attr('title', 'Started').attr('bt-xtitle', 'Started').html('S');
          break;
          case 'task_order_done':
            ui.item.addClass('accepted');
            ui.item.find('.state input[type=hidden]').val('accepted');
            ui.item.find('.current-state').addClass('accepted').attr('title', 'Accepted').attr('bt-xtitle', 'Accepted').html('A');
          break;
        }
      },
      stop: function(event, ui) {
        var count = 1;
        //Update the orders of the tasks
        ui.item.parent().children().each(function() {
          $(this).find('.order input[type=hidden]').val(count)
          ++count;
        });
        //Save changes (ajax)
        $('#task_order_form').submit();
      }
    }).disableSelection();
  }  
  //Collapse all tasks in this panel
  $('div.task_order > h3 div.collapse a').click(function() {
    $(this).parents('.task_order').find('div.tasks > .task .content').hide();
    $(this).parents('.task_order').find('div.tasks > .task .heading .expand-collapse').addClass('expand').removeClass('collapse');
    $(this).parents('.task_order').find('div.tasks > .task').removeClass('expanded');
  })
  
  //Expand all tasks in this panel
  $('div.task_order > h3 div.expand a').click(function() {
    $(this).parents('.task_order').find('div.tasks > .task .content').show();
    $(this).parents('.task_order').find('div.tasks > .task .heading .expand-collapse').removeClass('expand').addClass('collapse');
    $(this).parents('.task_order').find('div.tasks > .task').addClass('expanded');
    $(this).parents('.task_order').find('div.tasks > .task > .content').each(function() {
      //Update description
      var description = $(this).find('.description');
      if (description.text() == '') {
        description.addClass('loading');
        $.getJSON($(this).find('li.view a').attr('href'), function(data) {
          var text = '';
          if (data != null) {
            text = data.task.description;
          }
          description.html(text);
          description.removeClass('loading');
        });
      }
    });
  });

  //Toggle task
  $('div.task_order .task .expand-collapse a').click(function() {
    $(this).parent().toggleClass('expand').toggleClass('collapse');
    var description = $(this).parents('.task').find('.content .description');
    //Update description
    if (description.text() == '') {
      description.addClass('loading');
      $.getJSON($(this).parents('.task').find('.content li.view a').attr('href'), function(data) {
        var text = '';
        if (data != null) {
          text = data.task.description;
        }
        description.html(text);
        description.removeClass('loading');
     });
    }
    $(this).parents('.task').find('.content').toggle();
    $(this).parents('.task').toggleClass('expanded');
  }).parents('.task').find('.content').hide();

  if (IS_STAFF) {
    $('.task .heading').each(function() {
      $(this).append('<span class="clock start"><a href="#"><img src="/images/clock-start.png" alt="Clock"></a></span>');
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

  
    $('div.task_order div.task:not(.edit-active) span.cypher').live('click', function() {
        var self =$(this);
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
}

//Remove state classes from a task
function removeTaskState(task) {
  task.find('.current-state').attr('class', 'current-state');
  task.removeClass('not_started');
  task.removeClass('started');
  task.removeClass('delivered');
  task.removeClass('rejected');
  task.removeClass('accepted');
  task.removeClass('change_of_scope');
  task.removeClass('duplicate');
}

function updateClockTitle() {
  $('.clock.stop').each(function() {
      var task_id = $(this).parents('div.task').find('.handle .task-id').val();
      var started = readCookie('timesliceStarted:'+task_id);
      var now = new Date();
      var time = pad0(now.getHours()) + ':' + pad0(now.getMinutes()) + ':' + pad0(now.getSeconds());
      var title = started + ' - ' + time;
      $(this).find('img').attr('title', title);
    });
  setTimeout("updateClockTitle()", 1000);
}