$(document).ready(function() {
  projectOrder();
  // Ajaxifies the project order form
  ajaxifyForm($('#project_order_form'), function(data) {
    //project variable comes from the request
    $.each(projects, function(index, project) {
      $('#project_states_' + project.project.id).val(project.project.state);
      $('#project_orders_' + project.project.id).val(project.project.order);
    });
  });
});

function projectOrder() {
  //Add blank anchor to the handles
  $('div.project_order div.projects div.handle').each(function() {
    $(this).prepend('<a href=""></a>');
  });
  //Add blank anchor to the expand and collapse elements
  $('div.expand-collapse').each(function() {
    $(this).prepend('<a href=""></a>');
  });
  //Hide submit button
  $('#project_order_form input[value=Update order]').hide();
  //Return false on collapse/expand and handle anchors
  $('.expand-collapse a, .handle a').click(function() { return false; });

  // Hide projects that are not mine on the dashboard
  $('body.dashboard div.project_order > div.projects div.project:not(.mine) .handle').hide();

  //Makes the projects sortable
  $('div.project_order > div.projects').sortable({
    'handle': '.handle',
    'cursor': 'move',
    // Disable sort on projects that are not mine on the dashboard
    'cancel': 'body.dashboard div.project_order > div.projects div.project:not(.mine)',
    'connectWith': 'div.project_order div.projects',
    'delay': 250,
    'placeholder': 'ui-state-highlight',
    receive: function(event, ui) {
      removeProjectState(ui.item);
      // Changes the hidden 'state' field, 'current-state' div, and classes to
      // the new values
      switch (ui.item.parents('div.project_order').attr('id')) {
      case 'project_order_proposed':
        ui.item.addClass('proposed');
        ui.item.find('.state input[type=hidden]').val('proposed');
        ui.item.find('.current-state').addClass('proposed').attr('title', 'Proposed').attr('bt-xtitle', 'Proposed').html('P');
        break;
      case 'project_order_current':
        ui.item.addClass('current');
        ui.item.find('.state input[type=hidden]').val('current');
        ui.item.find('.current-state').addClass('current').attr('title', 'Current').attr('bt-xtitle', 'Current').html('S');
        break;
      case 'project_order_postponed':
        ui.item.addClass('postponed');
        ui.item.find('.state input[type=hidden]').val('postponed');
        ui.item.find('.current-state').addClass('postponed').attr('title', 'Postponed').attr('bt-xtitle', 'Postponed').html('P');
        break;
      case 'project_order_complete':
        ui.item.addClass('complete');
        ui.item.find('.state input[type=hidden]').val('complete');
        ui.item.find('.current-state').addClass('complete').attr('title', 'Complete').attr('bt-xtitle', 'Complete').html('C');
        break;
      }
    },
    stop: function(event, ui) {
      //Update the orders of the projects
      $('div.projects.ui-sortable').each(function() {
        var count = 1;
        $(this).children().each(function() {
          $(this).find('.order input[type=hidden]').val(count);
          ++count;
        });
      });
      //Save changes (ajax)
      $('#project_order_form').submit();
    }
  }).disableSelection();
  
  //Collapse all projects in this panel
  $('div.project_order > h3 div.collapse a').click(function() {
    $(this).parents('.project_order').find('div.projects > .project .content').hide();
    $(this).parents('.project_order').find('div.projects > .project .heading .expand-collapse').addClass('expand').removeClass('collapse');
    $(this).parents('.project_order').find('div.projects > .project').removeClass('expanded');
  })
  
  //Expand all projects in this panel
  $('div.project_order > h3 div.expand a').click(function() {
    $(this).parents('.project_order').find('div.projects > .project .content').show();
    $(this).parents('.project_order').find('div.projects > .project .heading .expand-collapse').removeClass('expand').addClass('collapse');
    $(this).parents('.project_order').find('div.projects > .project').addClass('expanded');
    $(this).parents('.project_order').find('div.projects > .project').each(function() {
	  var project = $(this);
	  if (project.find('.progress-details').length == 0) {
		project.find('.content').addClass('loading');
		var project_path = project.find('.heading .title a').attr('href');
		project.find('.content').prepend(projectProgressDetails(project_path, project, function() {
		  project.find('.content').addClass('loading');
		}));
	  }
	});
  });
  
  //Toggle project
  $('div.project_order .project .expand-collapse a').click(function() {
	var project = $(this).parents('.project');
	project.toggleClass('expanded');
	$(this).parent().toggleClass('expand').toggleClass('collapse');
	project.find('.content').toggle();
	if (project.find('.progress-details').length == 0) {
	  project.find('.content').addClass('loading');
	  var project_path = project.find('.heading .title a').attr('href');
	  projectProgressDetails(project_path, project);;
	}
	
	
  }).parents('.project').find('.content').hide();
  
  
  
  //Remove state classes from a project
  function removeProjectState(project) {
    project.find('.current-state').attr('class', 'current-state');
    project.removeClass('proposed');
    project.removeClass('current');
    project.removeClass('postponed');
    project.removeClass('complete');
  }


  function projectProgressDetails(project_path, project) {
    $.getJSON(project_path, function(data) {
	  var out = '<ul class="progress-details">';
	  out += '<li class="todo">' + data.project.todo + ' todo,</li>';
	  out += '<li class="doing">' + data.project.doing + ' doing,</li>';
	  out += '<li class="done">' + data.project.done + ' done</li>';
	  out += '</ul>';
	  project.find('.content').prepend(out);
	  project.find('.content').removeClass('loading');
	});
  }
}