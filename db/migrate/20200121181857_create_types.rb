class CreateTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :types do |t|
      t.string :name
      t.timestamps
      t.belongs_to :vocabulary
    end
  end
end
