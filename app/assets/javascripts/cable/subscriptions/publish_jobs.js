$(document).ready(function() {
    // subscribe to all relevant publish jobs on this page
    document.querySelectorAll('.publish-job[data-subscribe="true"]').forEach(function(publishJobRow) {
      const {publishJobId} = publishJobRow.dataset;
      App.cable.subscriptions.create({channel: 'PublishJobChannel', id: publishJobId}, {
        connected: function() {
          console.log('Subscription confirmed for PublishJob ' + publishJobId);
          this.perform('publish_job_status_check', {jobId: publishJobId});
        },

        received: function (data) {
          console.log('Received message for PublishJob ' + publishJobId)
          // Update the status widget for the job in the received message
          const {job, statusWidget} = data;
        //   const {binaries_count, item_count} = job;
          console.log('ImportJob ' + importJobId + ' state: ' + job.state + '; progress: ' + job.progress);
          let oldWidget = $('[data-job-id="' + job.id + '"]');
          if (oldWidget && statusWidget) {
            oldWidget.replaceWith(statusWidget)
          }
          // update count columns
          let td = document.querySelector('[data-job-id="' + job.id + '"]');
        //   td.parentElement.querySelector('.binaries-count').innerHTML = binaries_count;
        //   td.parentElement.querySelector('.item-count').innerHTML = item_count;
        },

        disconnected: function() {
          console.log('Disconnected from PublishJob ' + publishJobId);
        }
      });
      console.log('Subscribed to PublishJobChannel, id: ' + publishJobId);
    });
  });
