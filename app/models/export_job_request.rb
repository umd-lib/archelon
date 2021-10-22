# frozen_string_literal: true

# A STOMP message to control an export job
class ExportJobRequest < ApplicationRecord
  belongs_to :export_job

  def headers # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    {
      PlastronCommand: 'export',
      PlastronJobId: job_id,
      'PlastronArg-output-dest': File.join(EXPORT_CONFIG[:base_destination], export_job.filename),
      'PlastronArg-on-behalf-of': export_job.cas_user.cas_directory_id,
      'PlastronArg-format': export_job.format,
      'PlastronArg-timestamp': export_job.timestamp,
      'PlastronArg-export-binaries': export_job.export_binaries.to_s,
      persistent: 'true'
    }.tap do |headers|
      headers['PlastronArg-binary-types'] = export_job.selected_mime_types.join(',') if export_job.export_binaries
    end
  end

  def body
    export_job.uris
  end

  def submitted!
    export_job.in_progress!
  end

  def error!
    export_job.export_error!
  end
end
