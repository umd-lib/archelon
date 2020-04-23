# frozen_string_literal: true

namespace :stomp do
  desc 'Start a STOMP listener'
  task listen: :environment do
    listener = StompListener.new.connect || exit(1)

    listener.subscribe(:jobs_completed) do |stomp_msg|
      message = PlastronMessage.new(stomp_msg)
      puts "Updating job status for #{message.job_id}"
      message.find_job.update_status(message)
    end

    listener.subscribe(:job_status) do |stomp_msg|
      message = PlastronMessage.new(stomp_msg)
      puts "Updating job progress for #{message.job_id}"
      message.find_job.update_progress(message)
    end

    loop { sleep(0.1) }
  end
end
