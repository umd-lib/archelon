class AddRemoteServerToImportJob < ActiveRecord::Migration[5.2]
  def change
    add_column :import_jobs, :remote_server, :string
  end
end
