class RemovePlastronOperationIdFromExportJob < ActiveRecord::Migration[5.2]
  def change
    remove_column :export_jobs, :plastron_operation_id, :integer
  end
end
