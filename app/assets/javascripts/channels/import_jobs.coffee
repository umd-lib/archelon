App.import_jobs = App.cable.subscriptions.create "ImportJobsChannel",
  collection: -> $("[data-channel='import_jobs']")

  connected: ->
      @followImportJobs()
      @installPageChangeCallback()

  received: (data) ->
    # Trigger a page reload
    location.reload()

  check_for_pending: ->
    # This method is needed because of a race condition between job status
    # updates and page loads. When loading the page, a job status message
    # may be sent before the page is subscribed to the channel.
    #
    # This method checks whether any jobs have a pending/in progress state
    # where a missed message may have occurred. If there are such jobs,
    # then the "import_job_status_check" method on ImportJobChannel is
    # called, so that if a message was missed, there will be a rebroadcast.
    #
    # If all jobs are in a "stable" status, or in a status where another message
    # will definitely occur, then the "import_job_status_check" method is not
    # called.
    requestUpdate = false;
    jobId = ""
    jobs = []
    for c in @collection()
      stage = c.dataset.stage
      status = c.dataset.status

      job_may_need_update = (stage == "validate" && status == "in_progress")
      if job_may_need_update
        jobs.push({jobId: c.dataset.jobId, stage: c.dataset.stage, status: c.dataset.status})
        requestUpdate = true

    if requestUpdate
      @perform 'import_job_status_check', { jobs }

  followImportJobs: ->
    # Calls "follow" or "unfollow" on ImportJobsChannel, based on whether
    # the current page is interested in messages from the channel.
    if @collection().length > 0
      # If we have divs tagged with "data-channel='import_jobs'", then
      # we want to receive messages from the channel
      @perform 'follow'
      @check_for_pending()
    else
      # otherwise we don't want to receive messages from the channel
      @perform 'unfollow'

  installPageChangeCallback: ->
    unless @installedPageChangeCallback
      @installedPageChangeCallback = true
      $(document).on 'turbolinks:load', -> App.import_jobs.followImportJobs()
