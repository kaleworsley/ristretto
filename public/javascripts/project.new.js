$(document).ready(function() {
    $('input#is_member').change(function () {
      if($(this).attr("checked")) {
        $('#stakeholder_role_div').show();
        return;
      }
      $('#stakeholder_role_div').hide();
    });
    if ($('input#is_member:checked').val() == null) {
      $('#stakeholder_role_div').hide();
    }

    $('#project_deadline').datepicker({
      dateFormat: 'yy-mm-dd',
      changeMonth: true,
      changeYear: true,
      showOtherMonths: true,
      selectOtherMonths: true,
      showAnim: ''
    });
});
