class AddStateToExportJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :export_jobs, :state, :integer
  end
end
