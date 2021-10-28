# frozen_string_literal: true

require 'resque/tasks'
require 'resque/scheduler/tasks'

namespace :resque do
  task 'setup' => :environment do
    Resque.before_fork = proc do |_job|
      ActiveRecord::Base.connection.disconnect!
    end
    Resque.after_fork = proc do |_job|
      ActiveRecord::Base.establish_connection
    end
  end

  task setup_schedule: :setup do
    require 'resque-scheduler'
    Resque.schedule = YAML.load_file(Rails.root.join('config', 'resque_schedule.yml'))
    require './app/jobs/download_url_expiration_job'
  end

  task scheduler: :setup_schedule
end
