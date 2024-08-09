class CreatePublicKeys < ActiveRecord::Migration[5.2]
  def change
    create_table :public_keys do |t|
      t.string :key
      t.belongs_to :cas_user

      t.timestamps
    end
  end
end
