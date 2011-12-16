$(function() {
	if (readCookie('user_credentials') != null) {
		$(document).bind('keyup', 'alt+/ ctrl+/ meta+/ ctrl+f', function() {
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
	  height: '110',
	  width: '70%',
    show: 'fade',
    modal: true
  });

  $('#search_popup input').autocomplete({
    source: '/search.json'
  });
}