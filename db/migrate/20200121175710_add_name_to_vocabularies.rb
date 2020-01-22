class AddNameToVocabularies < ActiveRecord::Migration[5.2]
  def change
    add_column :vocabularies, :name, :string
  end
end
