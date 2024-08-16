class AddBinariesToExportJob < ActiveRecord::Migration[5.2]
  def change
    add_column :export_jobs, :export_binaries, :boolean
    add_column :export_jobs, :binaries_size, :bigint
    add_column :export_jobs, :binaries_count, :integer
  end
end
