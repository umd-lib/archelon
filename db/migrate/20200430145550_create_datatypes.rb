class CreateDatatypes < ActiveRecord::Migration[5.2]
  def change
    create_table :datatypes do |t|
      t.string :identifier
      t.references :vocabulary, foreign_key: true

      t.timestamps
    end
  end
end
