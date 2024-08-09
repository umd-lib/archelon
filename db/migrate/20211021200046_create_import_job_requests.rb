class CreateImportJobRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :import_job_requests do |t|
      t.references :import_job, foreign_key: true
      t.boolean :validate_only
      t.boolean :resume

      t.timestamps
    end
  end
end
