App.export_jobs = App.cable.subscriptions.create "ExportJobsChannel",
  collection: -> $("[data-channel='export_jobs']")

  connected: ->
      @followExportJobs()
      @installPageChangeCallback()

  received: (data) ->
    # Trigger a page reload
    location.reload()

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
