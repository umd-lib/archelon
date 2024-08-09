class AddJobIdToImportJobRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :import_job_requests, :job_id, :string
  end
end
