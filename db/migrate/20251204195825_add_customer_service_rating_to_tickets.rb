class AddCustomerServiceRatingToTickets < ActiveRecord::Migration[8.0]
  def change
    add_column :tickets, :customer_service_rating, :integer
    add_column :tickets, :customer_service_feedback, :text
    add_column :tickets, :customer_service_rated_at, :datetime

    # Optional, if you like DB-level check (Postgres/MySQL 8+)
    # reversible do |dir|
    #   dir.up do
    #     execute <<~SQL
    #       ALTER TABLE tickets
    #       ADD CONSTRAINT check_customer_service_rating_range
    #       CHECK (customer_service_rating IS NULL OR (customer_service_rating BETWEEN 1 AND 5));
    #     SQL
    #   end
    #   dir.down do
    #     execute "ALTER TABLE tickets DROP CONSTRAINT IF EXISTS check_customer_service_rating_range"
    #   end
    # end
  end
end
