class FixSpellingErrorVisibility < ActiveRecord::Migration[5.2]
  def change
    remove_column :publish_jobs, :visbility
    add_column :publish_jobs, :visibility, :boolean
  end
end
