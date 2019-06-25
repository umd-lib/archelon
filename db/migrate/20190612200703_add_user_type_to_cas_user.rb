class AddUserTypeToCasUser < ActiveRecord::Migration
  def change
    add_column :cas_users, :user_type, :string
  end
end
