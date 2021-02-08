# frozen_string_literal: true

# Encapsulates a Plastron import job request message
class ImportJobRequest
  def initialize(job_id, import_job, validate_only)
    @job_id = job_id
    @job = import_job
    @validate_only = validate_only
  end

  def headers # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    {
      PlastronCommand: 'import',
      PlastronJobId: @job_id,
      'PlastronArg-model': @job.model,
      'PlastronArg-name': @job.name,
      'PlastronArg-on-behalf-of': @job.cas_user.cas_directory_id,
      'PlastronArg-member-of': @job.collection,
      'PlastronArg-timestamp': @job.timestamp,
      'PlastronArg-structure': @job.collection_structure.to_s
    }.tap do |headers|
      headers['PlastronArg-access'] = "<#{access}>" if @job.access.present?
      headers['PlastronArg-validate-only'] = 'True' if @validate_only
      headers['PlastronArg-binaries-location'] = @job.binaries_location if @job.binaries_location.present?
    end
  end

  def body
    @job.metadata_file.download
  end
end
