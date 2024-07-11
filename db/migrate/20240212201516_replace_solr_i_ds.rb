class ReplaceSolrIDs < ActiveRecord::Migration[5.2]
  def change
    remove_column :publish_jobs, :solr_id
    add_column :publish_jobs, :solr_ids, :text, default: [].to_yaml
  end
end
