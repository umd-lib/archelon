class AddActiveToCasUser < ActiveRecord::Migration[7.1]
  def change
    add_column :cas_users, :active, :boolean, default: true
  end
end
