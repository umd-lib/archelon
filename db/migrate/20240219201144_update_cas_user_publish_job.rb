class UpdateCasUserPublishJob < ActiveRecord::Migration[5.2]
  def change
    remove_column :publish_jobs, :cas_user
    add_reference :publish_jobs, :cas_user, index: true, foreign_key: true
  end
end
