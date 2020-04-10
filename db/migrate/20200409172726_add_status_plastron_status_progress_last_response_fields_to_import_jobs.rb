class AddStatusPlastronStatusProgressLastResponseFieldsToImportJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :import_jobs, :status, :string
    add_column :import_jobs, :plastron_status, :string
    add_column :import_jobs, :progress, :integer
    add_column :import_jobs, :last_response, :text
  end
end
