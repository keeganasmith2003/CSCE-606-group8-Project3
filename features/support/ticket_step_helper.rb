module TicketStepHelper
  def current_ticket!
    # 1) use @ticket if already set
    return @ticket if defined?(@ticket) && @ticket.present?

    # 2) try to parse /tickets/:id from the current path
    if page.respond_to?(:current_path)
      if (m = page.current_path.match(%r{\A/tickets/(\d+)}))
        @ticket = Ticket.find(m[1])
        return @ticket
      end
    end

    # 3) fallback: latest ticket (good enough for single-ticket scenarios)
    @ticket = Ticket.order(:id).last
    raise "No ticket found in scenario context" unless @ticket
    @ticket
  end
end

World(TicketStepHelper)
