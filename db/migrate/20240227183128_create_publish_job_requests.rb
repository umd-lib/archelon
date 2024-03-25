class CreatePublishJobRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :publish_job_requests do |t|

      t.timestamps
    end
  end
end
