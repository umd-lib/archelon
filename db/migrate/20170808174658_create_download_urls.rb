class CreateDownloadUrls < ActiveRecord::Migration
  def change
    create_table :download_urls do |t|
      t.string :token
      t.string :url
      t.string :title
      t.text :notes
      t.string :mimetype
      t.string :creator
      t.boolean :enabled
      t.string :request_ip
      t.string :request_user_agent
      t.datetime :accessed_at
      t.datetime :download_completed_at

      t.timestamps null: false
    end
    add_index :download_urls, :token, unique: true
  end
end
