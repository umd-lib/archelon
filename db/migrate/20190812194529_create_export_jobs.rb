class CreateExportJobs < ActiveRecord::Migration
  def change
    create_table :export_jobs do |t|
      t.string :format
      t.references :cas_user, index: true, foreign_key: true
      t.timestamp :timestamp
      t.string :name
      t.integer :item_count
      t.string :status

      t.timestamps null: false
    end
  end
end
