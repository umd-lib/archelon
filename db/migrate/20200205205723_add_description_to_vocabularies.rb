class AddDescriptionToVocabularies < ActiveRecord::Migration[5.2]
  def change
    add_column :vocabularies, :description, :string
  end
end
