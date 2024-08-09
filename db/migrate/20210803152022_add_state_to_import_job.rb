class AddStateToImportJob < ActiveRecord::Migration[5.2]
  def change
    add_column :import_jobs, :state, :integer
  end
end
