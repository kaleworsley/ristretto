/**
 * @file
 * Generic form ajaxification script.
 *
 * @author Kale Worsley kale@egressive.com
 */
$(document).ready(function() {
  //Turns all form.ajax forms into a generic ajax form
  $('form.ajax').each(function() {
    ajaxifyForm($(this));
  });
});

//Ajaxifies a form
function ajaxifyForm(form, successCallback, errorCallback, type, method, action) {
  //Set the throbber image
  $('input[type=submit]', form).throbber({image: '/images/throbber.gif'});
  //Submit handler
  form.submit(function (){
    $.ajax({
      type: method || form.attr('method'),
      url: action || form.attr('action'),
      data: form.serialize(),
      success: function (data, textStatus, XMLHttpRequest) {
        form[0].reset();
        flashMessage();
        $.throbberHide();
        //Execute callback, if it exists
        if (typeof successCallback == 'function') {
	      successCallback(data, textStatus, XMLHttpRequest);
        }
      },
      error: function(XMLHttpRequest, textStatus, errorThrown) {
	    flashMessage();
        $.throbberHide();
	    if (typeof errorCallback == 'function') {
	      errorCallback(data, textStatus, XMLHttpRequest);
        }
      },
      dataType: type || "script"
    });
    return false;
  });

  $('input[type=submit]', form).click(function() {
    $(this).parents('form').submit();
    return false;
  });
}