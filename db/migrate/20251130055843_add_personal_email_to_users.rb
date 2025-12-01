class AddPersonalEmailToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :personal_email, :string
  end
end
