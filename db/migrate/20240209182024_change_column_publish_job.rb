class ChangeColumnPublishJob < ActiveRecord::Migration[5.2]
  def change
    rename_column :publish_jobs, :document, :solr_id
  end
end
