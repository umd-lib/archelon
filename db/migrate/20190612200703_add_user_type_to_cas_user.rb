class AddUserTypeToCasUser < ActiveRecord::Migration[4.2]
  def change
    add_column :cas_users, :user_type, :string
  end
end
