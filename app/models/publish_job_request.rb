class PublishJobRequest < ApplicationRecord
  belongs_to :publish_job

  def headers # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    {
      PlastronCommand: publish_job.publish ? 'publish' : 'unpublish',
      PlastronJobId: job_id,
      'PlastronArg-name': publish_job.name,
      'PlastronArg-on-behalf-of': publish_job.cas_user.cas_directory_id,
    }.tap do |headers|
      headers['PlastronArg-resume'] = 'True' if resume
    end
  end

  def body
    publish_job.solr_ids.join('\n')
  end
end
