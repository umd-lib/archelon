class DropVocabularyTables < ActiveRecord::Migration[5.2]
  def change
    # Drop Vocabulary tables, as vocabulary management functionality has
    # been removed from Archelon
    drop_table :datatypes
    drop_table :individuals
    drop_table :types
    drop_table :vocabularies
  end
end
