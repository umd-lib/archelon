class AddCasUserAndStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :publish_jobs, :cas_user, :string
    add_column :publish_jobs, :status, :string
  end
end
