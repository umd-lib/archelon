$(document).ready(function() {
  document.querySelectorAll('.export-job[data-subscribe="true"]').forEach(function(exportJobRow) {
    const {exportJobId} = exportJobRow.dataset;
    App.cable.subscriptions.create({channel: 'ExportJobsChannel', id: exportJobId}, {
      connected: function() {
        console.log('Subscription confirmed for ExportJob ' + exportJobId);
        this.perform('export_job_status_check', {jobId: exportJobId});
      },

      received: function(data) {
        console.log('Received message for ExportJob ' + exportJobId)
        // Update the display for the export job
        const {job, statusWidget} = data;
        console.log('ExportJob ' + exportJobId + ' state: ' + job.state + '; progress: ' + job.progress);
        let oldWidget = $('[data-job-id="' + job.id + '"]');
        if (oldWidget && statusWidget) {
          oldWidget.replaceWith(statusWidget)
        }
      },

      disconnected: function() {
        console.log('Disconnected from ExportJob ' + exportJobId);
      }
    });
    console.log('Subscribed to ExportJobsChannel, id: ' + exportJobId);
  });
});
