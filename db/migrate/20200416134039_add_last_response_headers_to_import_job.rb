class AddLastResponseHeadersToImportJob < ActiveRecord::Migration[5.2]
  def change
    add_column :import_jobs, :last_response_headers, :text
  end
end
