(function() {
  App.import_jobs = App.cable.subscriptions.create("ImportJobsChannel", {
    importJobsDivs: function() {
      return document.querySelectorAll('[data-channel="import_jobs"]');
    },

    connected: function() {
      this.followImportJobs();
      return this.installPageChangeCallback();
    },

    received: function(data) {
      // Update the status widget for each job in the received message
      data.import_jobs.forEach(function(msg){
        const {job, statusWidget} = msg;
        let oldWidget = $('[data-job-id="' + job.id + '"]')
        if (oldWidget && statusWidget) {
          oldWidget.replaceWith(statusWidget)
        }
      });
    },

    checkForPending: function() {
      // This method is needed because of a race condition between job status
      // updates and page loads. When loading the page, a job status message
      // may be sent before the page is subscribed to the channel.
      //
      // This method checks whether any jobs have a pending/in progress state
      // where a missed message may have occurred. If there are such jobs,
      // then the "import_job_status_check" method on ImportJobChannel is
      // called, so that if a message was missed, there will be a rebroadcast.
      //
      // If all jobs are in a "stable" status, or in a status where another
      // message will definitely occur, then the "import_job_status_check"
      // method will not send a message to the server.

      let jobsToUpdate = [];

      this.importJobsDivs().forEach(function(div) {
        let state = div.dataset.state;
        if (state === "in_progress" || state.endsWith("_pending")) {
          jobsToUpdate.push({ jobId: div.dataset.jobId, state: state });
        }
      });

      if (jobsToUpdate.length > 0) {
        return this.perform('import_job_status_check', {
          jobs: jobsToUpdate
        });
      }
    },

    followImportJobs: function() {
      // Calls "follow" or "unfollow" on ImportJobsChannel, based on whether
      // the current page is interested in messages from the channel.
      if (this.importJobsDivs().length > 0) {
        // If we have divs tagged with "data-channel='import_jobs'", then
        // we want to receive messages from the channel
        this.perform('follow');
        return this.checkForPending();
      } else {
        // otherwise we don't want to receive messages from the channel
        return this.perform('unfollow');
      }
    },

    installPageChangeCallback: function() {
      if (!this.installedPageChangeCallback) {
        this.installedPageChangeCallback = true;
        return $(document).on('turbolinks:load', function() {
          return App.import_jobs.followImportJobs();
        });
      }
    }
  });

}).call(this);
