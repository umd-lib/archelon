import consumer from "./consumer"

$(document).ready(function() {
  document.querySelectorAll('.publish-job[data-subscribe="true"]').forEach(function(publishJobRow) {
    const {publishJobId} = publishJobRow.dataset;
    consumer.subscriptions.create({channel: 'PublishJobsChannel', id: publishJobId}, {
      connected() {
        console.log('Subscription confirmed for PublishJob ' + publishJobId);
        this.perform('publish_job_status_check', {jobId: publishJobId});
      },

      disconnected() {
        console.log('Disconnected from PublishJob ' + publishJobId);
      },

      received(data) {
        console.log('Received message for PublishJob ' + publishJobId)
        // Update the status widget for the job in the received message
        const {job, statusWidget} = data;
        console.log('PublishJob ' + publishJobId + ' state: ' + job.state + '; progress: ' + job.progress);
        let oldWidget = $('[data-job-id="' + job.id + '"]');
        if (oldWidget && statusWidget) {
          oldWidget.replaceWith(statusWidget)
        }
      },
    });
  });
});
