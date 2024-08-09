# frozen_string_literal: true

# A STOMP message to control an import job
class ImportJobRequest < ApplicationRecord
  belongs_to :import_job

  def headers # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    {
      PlastronCommand: 'import',
      PlastronJobId: job_id,
      'PlastronArg-model': import_job.model,
      'PlastronArg-name': import_job.name,
      'PlastronArg-on-behalf-of': import_job.cas_user.cas_directory_id,
      'PlastronArg-member-of': import_job.collection,
      'PlastronArg-timestamp': import_job.timestamp,
      'PlastronArg-structure': import_job.collection_structure.to_s,
      'PlastronArg-relpath': import_job.collection_relpath
    }.tap do |headers|
      headers['PlastronArg-access'] = "<#{import_job.access}>" if import_job.access.present?
      headers['PlastronArg-validate-only'] = 'True' if validate_only
      headers['PlastronArg-binaries-location'] = import_job.binaries_location if import_job.binaries_location.present?
      headers['PlastronArg-resume'] = 'True' if resume
    end
  end

  def body
    import_job.metadata_file.download
  end

  def submitted!
    import_job.validate_in_progress! if import_job.validate_pending?
    import_job.import_in_progress! if import_job.import_pending?
  end

  def error!
    import_job.validate_error! if import_job.validate_pending?
    import_job.import_error! if import_job.import_pending?
  end
end
