class AddTeamToTickets < ActiveRecord::Migration[8.0]
  def change
    add_column :tickets, :team_id, :integer
    add_index  :tickets, :team_id
    add_foreign_key :tickets, :teams
  end
end
