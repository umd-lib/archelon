App.export_jobs = App.cable.subscriptions.create "ExportJobsChannel",
  collection: -> $("[data-channel='export_jobs']")

  connected: ->
    # Called when the subscription is ready for use on the server
    #
    # This timeout is in the Rails Action Cable "full-stack" example at
    # https://github.com/rails/actioncable-examples/blob/master/app/assets/javascripts/channels/comments.coffee
    # with the followig comment:
    #    FIXME: While we wait for cable subscriptions to always be finalized before sending messages
    #
    # Not clear if this is still necessary, but leaving it in for safety
    setTimeout =>
      @followExportJobs()
      @installPageChangeCallback()
    , 1000

  received: (data) ->
    # Called when data is received from the server
    export_job = data.export_job
    export_job_id = export_job['id']
    job_id_divs = $("[data-channel='export_jobs'][data-job-id='"+export_job_id+"']")

    job_id_divs.replaceWith(data.message)

  followExportJobs: ->
    # Calls "follow" or "unfollow" on ExportJobsChannel, based on whether
    # the current page is interested in messages from the channel.
    if @collection().length > 0
      # If we have divs tagged with "data-channel='export_jobs'", then
      # we want to receive messages from the channel
      @perform 'follow'
    else
      # otherwise we don't want to receive messages from the channel
      @perform 'unfollow'

  installPageChangeCallback: ->
    unless @installedPageChangeCallback
      @installedPageChangeCallback = true
      $(document).on 'turbolinks:load', -> App.export_jobs.followExportJobs()
