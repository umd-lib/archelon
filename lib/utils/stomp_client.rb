class StompClient
  def self.instance
    @@instance ||= new
  end

  private_class_method :new

  def initialize
    @stomp_client = Stomp::Client.new(hosts: [Rails.configuration.stomp_server])

    @stomp_client.subscribe Rails.configuration.queues[:export_jobs_completed] do |stomp_msg|
      update_export_job(stomp_msg)
    end

    # Faker to move export jobs to export jobs completed
    @stomp_client.subscribe Rails.configuration.queues[:export_jobs] do |msg|
      headers = msg.headers
      archelon_headers = headers.delete_if { |key, _| !key.start_with?('Archelon') }
      archelon_headers[:ArchelonExportJobStatus] = 'Ready'
      body = msg.body
      @stomp_client.publish Rails.configuration.queues[:export_jobs_completed], body, archelon_headers
    end
  end

  def publish(destination, message, headers = {})
    @stomp_client.publish destination, message, headers
  end

  def update_export_job(stomp_msg)
    puts "******** Stomp message ************"
    puts "Msg: #{stomp_msg}"
    puts "*******************************"
    headers = stomp_msg.headers
    export_job_id = headers['ArchelonExportJobId']
    export_job = ExportJob.find(export_job_id)
    export_job_status = headers['ArchelonExportJobStatus']
    export_job.status = export_job_status
    export_job.save
  end
end