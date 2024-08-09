class CreateIndividuals < ActiveRecord::Migration[5.2]
  def change
    create_table :individuals do |t|
      t.string :name
      t.string :label
      t.string :same_as
      t.timestamps
      t.belongs_to :vocabulary
    end
  end
end
