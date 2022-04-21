class CreateExportJobRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :export_job_requests do |t|
      t.references :export_job, foreign_key: true
      t.boolean :validate_only
      t.boolean :resume
      t.string :job_id

      t.timestamps
    end
  end
end
