class ChangeVisibilityToHidden < ActiveRecord::Migration[5.2]
  def change
    remove_column :publish_jobs, :visibility
    add_column :publish_jobs, :force_hidden, :boolean
  end
end
