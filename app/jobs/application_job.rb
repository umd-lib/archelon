# frozen_string_literal: true

# Base superclass for ActiveJobs
class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  # Method called by resque-scheduler to enqueue job in a queue
  #
  # This method is required because resque-scheduler does not directly
  # support ActiveJob. See https://stackoverflow.com/a/48551550
  #
  # Called on every run of the job, so a new instance of the job will be
  # created on every run
  #
  # Developer Note: If Resque has already run a job once, and the code in the
  # job is changed, the Resque workers MUST be restarted, as otherwise they will
  # continue to run the old implementation.
  def self.scheduled(queue, klass, *args)
    # create the job instance and pass the arguments
    job = klass.constantize.new(*args)

    # set correct queue
    job.queue_name = queue

    # enqueue job using ActiveJob API
    job.enqueue
  end
end
