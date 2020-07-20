class RenameRemoteServerColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :import_jobs, :remote_server, :binaries_location
  end
end
