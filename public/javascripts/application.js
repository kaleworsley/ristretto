$(document).ready(function() {
  // global onload functions
  //btifyTitles();
  flashMessage();
  markdownifyTextareas();
  $('.inlinebar').sparkline('html', {type: 'bar', barColor: '#0472CC'} );
  $('.inlinebar-red').sparkline('html', {type: 'bar', barColor: '#CC040B'} );
  $('textarea.resize:not(.processed)').TextAreaResizer();
});

//Start the fullscreen loading overlay
function loadingOverlayStart() {
  loadingOverlayStop();
  $('body').append('<div class="loading-overlay">Loading</div>');
  $('div.loading-overlay').disableSelection().fadeIn(500);
}

//Stop the fullscreen loading overlay
function loadingOverlayStop() {
  $('div.loading-overlay').fadeOut(500, function() {
    $(this).remove();
  });
}

//Turn the flash message divs into jquery purr pop notifications
function flashMessage() {
  $('body #page div.message.flash').purr().find('.close').html('<span class="ui-icon ui-icon-circle-close"></span>');
}

//Add a flash notice
function flashNotice(message) {
  $('#page').prepend('<div class="flash round-5 message notice not-sticky">' + message + '</div>');
  flashMessage();
}

//Add a flash error
function flashError(message) {
  $('#page').prepend('<div class="flash round-5 message error not-sticky">' + message + '</div>');
  flashMessage();
}

//Add a flash warning
function flashWarning(message) {
  $('#page').prepend('<div class="flash round-5 message warning not-sticky">' + message + '</div>');
  flashMessage();
}

//Turn textareas into WMD editors with preview
function markdownifyTextareas(selector, parent) {
  $((selector || 'textarea.markdown'), (parent || $('body'))).each(function() {
    $(this).wmd();
    $(this).not('.processed').TextAreaResizer();
    $(this).parents('.resizable-textarea').addClass('markdown');
  });
}

//Adds beauty tips to an element, using the title attr as the tip
function btifyTitles(selector, trigger, contentSelector) {
  $((selector || '#content *[title!=""]')).bt({
    trigger: trigger || 'hover',
    fill: '#F3F3F3',
    cornerRadius: 4,
    strokeWidth: 1,
    strokeStyle: '#939393',
    shadow: true,
    shadowOffsetX: 0,
    shadowOffsetY: 0,
    shadowBlur: 3,
    shadowColor: '#888',
    shadowOverlap: false,
    contentSelector: contentSelector || "$(this).attr('title')",
    noShadowOpts: {strokeStyle: '#999', strokeWidth: 2},
    shrinkToFit: true,
    cssStyles: {
      color: '#000'
    }
  });
}

//Create a cookie
function createCookie(name,value,days) {
  if (days) {
    var date = new Date();
    date.setTime(date.getTime()+(days*24*60*60*1000));
    var expires = "; expires="+date.toGMTString();
  }
  else var expires = "";
  document.cookie = escape(name)+"="+escape(value)+expires+"; path=/";
}

//Read a cookie
function readCookie(name) {
  var nameEQ = escape(name) + "=";
  var ca = document.cookie.split(';');
  for(var i=0;i < ca.length;i++) {
    var c = ca[i];
    while (c.charAt(0)==' ') c = c.substring(1,c.length);
    if (c.indexOf(nameEQ) == 0) return unescape(c.substring(nameEQ.length,c.length));
  }
  return null;
}

//Remove a cookie
function removeCookie(name) {
  createCookie(name,"",-1);
}

//Get an array of cookies
function getCookies() {
  var cookies = {};
  var ca = document.cookie.split('; ');
  for(var i=0;i < ca.length;i++) {
    var c = ca[i];
    var split = c.split('=');
    var name = unescape(split[0]);
    var value = unescape(split[1]);
    cookies[name] = value;
  }
  return cookies;
}
//Search for strings within a string
function searchAll(needle, haystack) {
  var found = 0;
  $.each(needle.split(' '), function(i, v) {
    if (haystack.search(v) > -1) {
      ++found;
    }
  });
  if (found == needle.split(' ').length) {
    return 1;
  }
  else {
    var s = '';
    $.each(haystack.split(' '), function(i, v) {
      s += v.substring(0, 1);
    });

    if (s.search(needle) != -1) {
      return 1;
    }
    else {
      return -1;
    }
  }
}

window.onbeforeunload = function() {
  beforeUnload = true;
}

function pad0(string) {
  var str = string.toString();
  if (str.length == 1) {
    return '0'+str;
  }
  else {
    return str;
  }
}

//Remove an item from an array
function removeItem(array, item) {
  var i = 0;
  while (i < array.length) {
    if (array[i] == item) {
      array.splice(i, 1);
    }
    else {
      i++;
    }
  }
  return array;
}

//Remove duplicate items from an array
function unique(a) {
  var r = new Array();
  o:for(var i = 0, n = a.length; i < n; i++)
  {
    for(var x = 0, y = r.length; x < y; x++)
    {
      if(r[x]==a[i]) continue o;
    }
    r[r.length] = a[i];
  }
  return r;
}

$(document).ready(function() {
  $('ul.primary-nav li.time ul li.unsaved-timeslice span.task').each(function() {
    var task_id = $(this).text();
    $(this).html('<a href="#"><img src="/images/cancel.png" /></a>');
    $(this).find('a').click(function() {
      if (confirm("Are you sure you want to remove this unsaved timeslice?")) {
	removeCookie('timesliceStarted:'+task_id);
	removeCookie('timesliceFinished:'+task_id);
	removeCookie('timesliceDescription:'+task_id);
	removeCookie('timesliceTimer:'+task_id);
	$(this).parents('li.unsaved-timeslice').slideUp();
      }
      return false;
    });
  });
});

$(document).ready(function() {
  $('pre code').each(function(i, e) {hljs.highlightBlock(e, '  ')});

  $('textarea.markdown').typing({
    stop: function() {
      $('.wmd-preview pre code').each(function(i, e) {hljs.highlightBlock(e, '  ')});
    },
    delay: 1000
  });

  //magicScroll('body.customers.customers-index div.customers > ul', 'li.customer');
  //magicScroll('body.users.users-index table.users tbody', 'table.users tbody tr');
  //magicScroll('body.projects.projects-index div.projects > ul', 'li.project');
  //magicScroll('body.tasks.tasks-index div.tasks > ul', 'li.task');
  //magicScroll('', '');

});

function magicScroll(contentSelector, itemSelector) {
  if ($(contentSelector).length == 1) {
    $(contentSelector).infinitescroll({
      navSelector  : "div.pagination",
      nextSelector : "div.pagination a.next_page",
      itemSelector : itemSelector,
      loadingImg : '/images/loading-light.gif',
      loadingText : '',
      donetext : ''
    });
  }
}

