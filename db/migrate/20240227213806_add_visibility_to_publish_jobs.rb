class AddVisibilityToPublishJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :publish_jobs, :visbility, :boolean
  end
end
