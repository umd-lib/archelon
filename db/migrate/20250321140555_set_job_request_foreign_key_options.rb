class SetJobRequestForeignKeyOptions < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :export_job_requests, :export_jobs
    add_foreign_key :export_job_requests, :export_jobs, on_delete: :cascade

    remove_foreign_key :import_job_requests, :import_jobs
    add_foreign_key :import_job_requests, :import_jobs, on_delete: :cascade

    remove_foreign_key :publish_job_requests, :publish_jobs
    add_foreign_key :publish_job_requests, :publish_jobs, on_delete: :cascade
  end
end
