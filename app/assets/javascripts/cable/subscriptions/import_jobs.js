$(document).ready(function() {
  // subscribe to all relevant import jobs on this page
  document.querySelectorAll('.import-job[data-subscribe="true"]').forEach(function(importJobRow) {
    const {importJobId} = importJobRow.dataset;
    App.cable.subscriptions.create({channel: 'ImportJobsChannel', id: importJobId}, {
      connected: function() {
        console.log('Subscription confirmed for ImportJob ' + importJobId);
        this.perform('import_job_status_check', {jobId: importJobId});
      },

      received: function (data) {
        console.log('Received message for ImportJob ' + importJobId)
        // Update the status widget for the job in the received message
        const {job, statusWidget} = data;
        const {binaries_count, item_count} = job;
        console.log('ImportJob ' + importJobId + ' state: ' + job.state + '; progress: ' + job.progress);
        let oldWidget = $('[data-job-id="' + job.id + '"]');
        if (oldWidget && statusWidget) {
          oldWidget.replaceWith(statusWidget)
        }
        // update count columns
        let td = document.querySelector('[data-job-id="' + job.id + '"]');
        td.parentElement.querySelector('.binaries-count').innerHTML = binaries_count;
        td.parentElement.querySelector('.item-count').innerHTML = item_count;
      },

      disconnected: function() {
        console.log('Disconnected from ImportJob ' + importJobId);
      }
    });
    console.log('Subscribed to ImportJobsChannel, id: ' + importJobId);
  });
});
