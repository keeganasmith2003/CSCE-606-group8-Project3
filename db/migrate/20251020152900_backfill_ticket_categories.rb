class BackfillTicketCategories < ActiveRecord::Migration[8.0]
  def up
    say_with_time("Backfilling ticket categories") do
      Ticket.reset_column_information
      Ticket.where(category: [ nil, "General", "" ]).update_all(category: "Technical Issue")
    end
  end

  def down
    # no-op
  end

  private

  class Ticket < ApplicationRecord
    self.table_name = "tickets"
  end
end
