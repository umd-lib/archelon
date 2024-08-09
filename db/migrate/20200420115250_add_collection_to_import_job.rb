class AddCollectionToImportJob < ActiveRecord::Migration[5.2]
  def change
    add_column :import_jobs, :collection, :string
  end
end
