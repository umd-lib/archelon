# frozen_string_literal: true

# A STOMP message to control an publish job
class PublishJobRequest < ApplicationRecord
  belongs_to :publish_job

  def headers
    {
      PlastronCommand: publish_job.publish ? 'publish' : 'unpublish',
      PlastronJobId: job_id,
      PlastronStatusURL: status_callback_url,
      'PlastronArg-name': publish_job.name,
      'PlastronArg-on-behalf-of': publish_job.cas_user.cas_directory_id,
      'PlastronArg-hidden': publish_job.force_hidden.to_s
    }.tap do |headers|
      headers['PlastronArg-resume'] = 'True' if resume
    end
  end

  def body
    publish_job.solr_ids.join("\n")
  end

  def status_callback_url
    STATUS_CALLBACK_BASE_URL + Rails.application.routes.url_helpers.update_status_of_publish_job_path(id: publish_job.id)
  end

  def submitted!
    publish_job.publish_in_progress! if publish_job.publish_pending?
  end

  def error!
    publish_job.publish_error! if publish_job.publish_pending?
  end
end
