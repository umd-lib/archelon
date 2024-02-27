class AddIndexAndResumePublishJobRequests < ActiveRecord::Migration[5.2]
  def change
    add_reference :publish_job_requests, :publish_job, index: true
    add_foreign_key :publish_job_requests, :publish_job
    add_column :publish_job_requests, :resume, :boolean
  end
end
