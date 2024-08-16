class RemoveStatusFromExportJob < ActiveRecord::Migration[5.2]
  def change
    remove_column :export_jobs, :status, :string
  end
end
