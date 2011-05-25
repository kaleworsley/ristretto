$(function() {
	if (readCookie('user_credentials') != null) {
		$(document).bind('keypress', 'ctrl+/', function() {
			showSearchPopup();
		});
	}
});

function showSearchPopup() {
	$('#search_popup').remove();
	
	$('body').append('<div id="search_popup" />');
	$('#search_popup').html('<form autocomplete="off" method="get" action="/search"><input name="q" /></form>');
  $('#search_popup').dialog({
	  title: 'Search',
	  resizable: false,
	  height: '100',
	  width: '70%'
  });
}