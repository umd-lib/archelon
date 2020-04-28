(function() {
  App.import_jobs = App.cable.subscriptions.create("ImportJobsChannel", {
    importJobsDivs: function() {
      return $("[data-channel='import_jobs']");
    },

    // Returns true if the page should be updated only for jobIds currently
    // on the page, false if the page should be updated on any message receipt.
    //
    // This function uses the "data-channel='import_jobs'" and
    // "data-only-update-on-match='true' attributes to determine if the
    // page is only interested in updates for jobIds that match the jobIds on
    // the page. Typically used for the "show" and "edit" pages which are only
    // showing one job.
    //
    // Other pages (with just one or more "[data-channel='import_jobs']" divs)
    // will update on any received message (typically used for "index" pages
    // that display a list of jobs).
    //
    // Having this distinction enables the same "received" function to be
    // used across pages (those that want to show new jobs, and those that
    // don't).
    onlyUpdateOnMatch: function() {
      return $("[data-channel='import_jobs'][data-only-update-on-match='true']").length > 0;
    },

    connected: function() {
      this.followImportJobs();
      return this.installPageChangeCallback();
    },

    received: function(data) {
      // Processes data received from the server.
      //
      // We can't easily distinguish between "new" and "updated" import jobs,
      // so this function uses the presence of "data-only-update-on-match='true'"
      // in a div (see the "only_update_on_match_divs") to indicate
      // that the page should only be reloaded if the given data includes
      // job ids that appear in one of the data-channel divs.
      //
      // If a "data-only-update-on-match='true'" attribute is not present
      // anywhere in the page, the page will always reload.
      var importJobsDivs, onlyUpdateOnMatch, divJobId, i, importJobs, j, jobId, jobIds,
          reloadPage;

      importJobs = data.import_jobs;

      jobIds = importJobs.map(function(job) {
        return job.id;
      });


      onlyUpdateOnMatch = this.onlyUpdateOnMatch();

      reloadPage = true

      if (onlyUpdateOnMatch) {
        importJobsDivs = this.importJobsDivs();
        reloadPage = false;
        for (i = 0; (i < importJobsDivs.length) && !reloadPage; i++) {
          divJobId = importJobsDivs[i].dataset.jobId;
          for (j = 0; j < jobIds.length; j++) {
            jobId = jobIds[j];

            if (jobId == divJobId) {
              reloadPage = true;
              break;
            }
          }
        }
      }

      if (reloadPage) {
        return location.reload();
      }
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
      var div, importJobsDivs, jobId, jobMayNeedUpdate, jobs, i,
          requestUpdate, stage, status;

      requestUpdate = false;
      jobId = "";
      jobs = [];

      importJobsDivs = this.importJobsDivs();

      for (i = 0; i < importJobsDivs.length; i++) {
        div = importJobsDivs[i];
        stage = div.dataset.stage;
        status = div.dataset.status;
        jobMayNeedUpdate = ((stage == "validate") && (status == "in_progress"));
        if (jobMayNeedUpdate) {
          jobs.push({ jobId: div.dataset.jobId, stage: div.dataset.stage, status: div.dataset.status });
          requestUpdate = true;
        }
      }
      if (requestUpdate) {
        return this.perform('import_job_status_check', {
          jobs: jobs
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
