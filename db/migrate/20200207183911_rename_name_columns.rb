class RenameNameColumns < ActiveRecord::Migration[5.2]
  def change
    %i(vocabularies individuals types).each do |table_name|
      rename_column table_name, :name, :identifier
    end
  end
end
