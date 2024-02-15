class CreatePublishJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :publish_jobs do |t|
      t.string :document
      t.timestamps
    end
  end
end
