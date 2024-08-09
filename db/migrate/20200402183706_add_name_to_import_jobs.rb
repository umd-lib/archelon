class AddNameToImportJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :import_jobs, :name, :string
  end
end
