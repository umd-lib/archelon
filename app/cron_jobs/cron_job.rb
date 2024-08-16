# frozen_string_literal: true

# Default base class for jobs that should be run on a cron-like schedule
class CronJob < ApplicationJob
  class_attribute :cron_expression

  class << self
    def schedule
      set(cron: cron_expression).perform_later unless scheduled?
    end

    def remove
      delayed_job.destroy if scheduled?
    end

    def scheduled?
      delayed_job.present?
    end

    def delayed_job
      Delayed::Job
        .where('handler LIKE ?', "%job_class: #{name}%")
        .first
    end
  end
end
