require 'resque-scheduler'
require 'resque/scheduler/server'

unless Rails.env.test?
  Resque.redis = 'localhost:6379'
  Resque.schedule = YAML.load_file(File.join(Rails.root, 'config/resque_schedule.yml')) # load the schedule

  # Require all job classes scheduled by resque-scheduler
  require './app/jobs/download_url_expiration_job'
end
