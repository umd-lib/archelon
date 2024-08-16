class AddNamePublishJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :publish_jobs, :name, :string
  end
end
