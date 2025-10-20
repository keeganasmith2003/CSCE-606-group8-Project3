# db/migrate/20251020051919_add_omniauth_and_role_to_users.rb
class AddOmniauthAndRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users do |t|
      t.string  :provider, null: false
      t.string  :uid,      null: false
      t.string  :email,    null: false
      t.string  :name
      t.string  :image_url
      t.string  :access_token
      t.string  :refresh_token
      t.datetime :access_token_expires_at
      t.integer :role, null: false, default: 0
    end

    add_index :users, [:provider, :uid], unique: true
    add_index :users, :email, unique: true
    add_index :users, :role
  end
end
