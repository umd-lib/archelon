class AddProgressToPublishJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :publish_jobs, :progress, :integer
  end
end
