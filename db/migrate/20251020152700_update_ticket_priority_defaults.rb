class UpdateTicketPriorityDefaults < ActiveRecord::Migration[8.0]
  def up
    change_column_default :tickets, :priority, from: nil, to: 1

    say_with_time("Setting default priority to medium on existing tickets") do
      Ticket.reset_column_information
      Ticket.where(priority: nil).update_all(priority: 1)
    end
  end

  def down
    change_column_default :tickets, :priority, from: 1, to: nil
  end

  private

  class Ticket < ApplicationRecord
    self.table_name = "tickets"
  end
end
