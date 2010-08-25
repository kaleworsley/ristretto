updated = null;
updateProject();
function updateProject() {
      var offline = false;
      $.getScript(location.href + '/watch', function(data) {
            if (data == '' && typeof(beforeUnload) == 'undefined') {
                  // Offline
                 flashError('The server is not responding. Changes will <strong>not</strong> be saved.');
                 offline = true;
            }
            if (updated == null) {
                  updated = data;
            }
            if (offline) {
                  $('div.task_order > div.tasks').sortable("disable");
            }
            else {
                  $('div.task_order > div.tasks').sortable("enable");
            }
            if (updated != data && !offline) {
                  loadingOverlayStart();
                  $('#tasks').load(location.href + ' #tasks', function() {
                        taskOrder();
                        loadingOverlayStop();
                        });
                  updated = data;
            }
            });

            setTimeout(updateProject, 5000);
}
