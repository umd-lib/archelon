class AddPublicationBoolean < ActiveRecord::Migration[5.2]
  def change
    add_column :publish_jobs, :publish, :boolean
  end
end
