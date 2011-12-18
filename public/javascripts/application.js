$(function() {
//$('.alert-message').alert();

});

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).parents('tr').before(content.replace(regexp, new_id));
}