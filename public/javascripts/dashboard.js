$(function() {
/*
  $(".resizeable").resizable({
    grid: 50,
    start: function() {
      $(this).css('opacity', '0.5');
      $(this).trigger('resize:start');
    },
    stop: function() {
      $(this).css('opacity', '1');
      $(this).trigger('resize:stop');
   	  var name = $(this).attr('id') + ':size';
	    var size = {
	      height: $(this).height(),
	      width: $(this).width()
	    }
	    store.set(name, size);
    }    
  });


  $(".draggable").draggable({
    handle: 'h3.title',
    start: function() {
      $(this).trigger('drag:start');
    },
    stop: function() {
      $(this).trigger('drag:stop');
  	  var name = $(this).attr('id') + ':position';
	    var position = {
	      top: $(this).css('top'),
	      left: $(this).css('left')
	    }
	    store.set(name, position);
    }
  });


  $('.resizeable').bind('resize:stop', function() {
    $('.panel', this).height($(this).height()-114);
  });

	$(".draggable").each(function() {
	  var name = $(this).attr('id') + ':position';
	  var position = store.get(name);
	  if (position) {
	    $(this).css('top', position.top);
 	    $(this).css('left', position.left);
	  }
	});
	
  $(".resizeable").each(function() {
	  var name = $(this).attr('id') + ':size';
	  var size = store.get(name);
	  if (size) {
	    $(this).height(size.height);
 	    $(this).width(size.width);
	  }
	  $('.panel', this).height($(this).height()-114);
	});
		
		*/
});
