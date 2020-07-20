class AddCountsToImportJob < ActiveRecord::Migration[5.2]
  def change
    add_column :import_jobs, :binaries_count, :integer
    add_column :import_jobs, :item_count, :integer
  end
end
