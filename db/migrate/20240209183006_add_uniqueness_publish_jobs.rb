class AddUniquenessPublishJobs < ActiveRecord::Migration[5.2]
  def change
      add_index :publish_jobs, :solr_id, unique: true
  end
end
