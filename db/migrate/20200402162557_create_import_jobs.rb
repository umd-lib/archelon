class CreateImportJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :import_jobs do |t|
      t.belongs_to :cas_user, foreign_key: true
      t.belongs_to :plastron_operation, foreign_key: true

      t.timestamps
    end
  end
end
