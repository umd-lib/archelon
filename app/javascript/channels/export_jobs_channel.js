import consumer from "./consumer"

$(document).ready(function() {
  document.querySelectorAll('.export-job[data-subscribe="true"]').forEach(function(exportJobRow) {
    const {exportJobId} = exportJobRow.dataset;
    consumer.subscriptions.create({ channel: "ExportJobsChannel", id: exportJobId }, {
      connected() {
        // Called when the subscription is ready for use on the server
        console.log('Subscription confirmed for ExportJob ' + exportJobId);
        this.perform('export_job_status_check', {jobId: exportJobId});
      },

      disconnected() {
        console.log('Disconnected from ExportJob ' + exportJobId);
      },

      received(data) {
        // Called when there's incoming data on the websocket for this channel
        console.log('Received message for ExportJob ' + exportJobId)
        // Update the display for the export job
        const {job, statusWidget} = data;
        console.log('ExportJob ' + exportJobId + ' state: ' + job.state + '; progress: ' + job.progress);
        let oldWidget = $('[data-job-id="' + job.id + '"]');
        if (oldWidget && statusWidget) {
          oldWidget.replaceWith(statusWidget)
        }
      },
    });
  });
});
