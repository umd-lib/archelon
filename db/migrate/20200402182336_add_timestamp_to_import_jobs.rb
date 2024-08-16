class AddTimestampToImportJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :import_jobs, :timestamp, :datetime
  end
end
