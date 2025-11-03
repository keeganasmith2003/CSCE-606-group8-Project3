class CreateTeamMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :team_memberships do |t|
      t.integer :team_id, null: false
      t.integer :user_id, null: false
      t.integer :role,    null: false, default: 0 # 0=member, 1=manager (optional)
      t.timestamps
    end
    add_index :team_memberships, [ :team_id, :user_id ], unique: true
    add_index :team_memberships, :user_id
    add_foreign_key :team_memberships, :teams
    add_foreign_key :team_memberships, :users
  end
end
