class AddStateToPublishJob < ActiveRecord::Migration[5.2]
  def change
    remove_column :publish_jobs, :status
    add_column :publish_jobs, :state, :integer
  end
end
