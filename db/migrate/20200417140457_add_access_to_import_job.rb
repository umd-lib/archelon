class AddAccessToImportJob < ActiveRecord::Migration[5.2]
  def change
    add_column :import_jobs, :access, :string
  end
end
