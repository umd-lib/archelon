class RemovePlastronOperationIdFromImportJob < ActiveRecord::Migration[5.2]
  def change
    remove_column :import_jobs, :plastron_operation_id, :integer
  end
end
