class RemoveImportJobsColumns < ActiveRecord::Migration[5.2]
  def change
    remove_columns :import_jobs, :stage, :status, :plastron_status, :last_response_headers, :last_response_body
  end
end
