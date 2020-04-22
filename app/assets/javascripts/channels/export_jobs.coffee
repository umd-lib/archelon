App.export_jobs = App.cable.subscriptions.create "ExportJobsChannel",
  collection: -> $("[data-channel='export_jobs']")

  connected: ->
    # FIXME: While we wait for cable subscriptions to always be finalized before sending messages
    setTimeout =>
      @followCurrentMessage()
      @installPageChangeCallback()
    , 1000

  received: (data) ->
    console.log("----export_jobs.coffee: Received " + data.export_job)
    export_job = data.export_job
    console.log("----export_jobs.coffee: export_job " + export_job)
    export_job_id = export_job['id']
    console.log("----export_jobs.coffee: export_job_id " + export_job_id)
    job_id_divs = $("[data-channel='export_jobs'][data-job-id='"+export_job_id+"']")
    console.log("----export_jobs.coffee: job_id_divs " + job_id_divs)
    console.log("----export_jobs.coffee: data.message " + data.message)

    job_id_divs.replaceWith(data.message)

  followCurrentMessage: ->
    console.log("----export_jobs.coffee: followCurrentMessage ")
    if jobId = @collection().data('job-id')
      console.log("----export_jobs.coffee: followCurrentMessage jobId="+jobId)
      @perform 'follow'
    else
      console.log("----export_jobs.coffee: followCurrentMessage unfollow")
      @perform 'unfollow'

  installPageChangeCallback: ->
    unless @installedPageChangeCallback
      @installedPageChangeCallback = true
      $(document).on 'turbolinks:load', -> App.export_jobs.followCurrentMessage()
