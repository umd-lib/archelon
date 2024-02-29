class AddJobIdPublishJobRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :publish_job_requests, :job_id, :string
  end
end
