class RenameLastResponseToLastResponseBodyInImportJob < ActiveRecord::Migration[5.2]
  def change
    rename_column :import_jobs, :last_response, :last_response_body
  end
end
