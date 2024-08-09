class AddStageToImportJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :import_jobs, :stage, :string
  end
end
