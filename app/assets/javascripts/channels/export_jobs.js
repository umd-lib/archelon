(function() {
  App.export_jobs = App.cable.subscriptions.create("ExportJobsChannel", {
    collection: function() {
      return $("[data-channel='export_jobs']");
    },
    connected: function() {
      this.followExportJobs();
      return this.installPageChangeCallback();
    },
    received: function(data) {
      // Trigger a page reload
      return location.reload();
    },
    followExportJobs: function() {
      // Calls "follow" or "unfollow" on ExportJobsChannel, based on whether
      // the current page is interested in messages from the channel.
      if (this.collection().length > 0) {
        // If we have divs tagged with "data-channel='export_jobs'", then
        // we want to receive messages from the channel
        return this.perform('follow');
      } else {
        // otherwise we don't want to receive messages from the channel
        return this.perform('unfollow');
      }
    },
    installPageChangeCallback: function() {
      if (!this.installedPageChangeCallback) {
        this.installedPageChangeCallback = true;
        return $(document).on('turbolinks:load', function() {
          return App.export_jobs.followExportJobs();
        });
      }
    }
  });

}).call(this);
