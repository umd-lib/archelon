class ImportJobsFileToUploadToMetadataFile < ActiveRecord::Migration[5.2]
  def change
    # ImportJob.connection.execute("UPDATE active_storage_attachments SET name = 'metadata_file' WHERE name = 'file_to_upload'")
  end
end
