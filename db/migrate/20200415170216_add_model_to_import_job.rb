class AddModelToImportJob < ActiveRecord::Migration[5.2]
  def change
    add_column :import_jobs, :model, :string
  end
end
