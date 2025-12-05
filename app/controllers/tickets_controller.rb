class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket, only: %i[show edit update destroy assign close approve reject rate]

  def index
    @tickets = policy_scope(Ticket).includes(:requester, :assignee, :team)
    apply_filters!
    load_filter_options
  end

  def mine
    authorize Ticket, :index?
    team_ids = current_user.teams.select(:id)

    @tickets = policy_scope(Ticket)
                 .where(assignee_id: current_user.id)
                 .or(policy_scope(Ticket).where(team_id: team_ids))
                 .includes(:requester, :assignee, :team)

    apply_filters!
    load_filter_options
    render :index
  end

  def show
    authorize @ticket
    @comments = @ticket.comments.includes(:author).chronological
    unless current_user&.agent? || current_user&.admin?
      if current_user == @ticket.requester
        @comments = @comments.where(visibility: Comment.visibilities[:public])
      else
        @comments = Comment.none
      end
    end
    @comment  = @ticket.comments.build(author: current_user, visibility: :public)
  end

  def new
    @ticket = Ticket.new(status: "open")
    authorize @ticket
  end

  def create
    @ticket = Ticket.new
    authorize @ticket
    @ticket.assign_attributes(ticket_params)
    @ticket.requester = current_user

    assign_team_based_on_category

    if Setting.auto_round_robin?
      @ticket.assignee = next_agent_in_rotation
    end

    if @ticket.save
      redirect_to @ticket, notice: "Ticket was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @ticket
  end

  def update
    authorize @ticket

    if params.dig(:ticket, :remove_attachment_ids).present?
      ids = Array(params.dig(:ticket, :remove_attachment_ids)).map(&:to_i)
      @ticket.attachments.each do |att|
        att.purge if ids.include?(att.id)
      end
    end

    if params.dig(:ticket, :attachments).present?
      Array(params.dig(:ticket, :attachments)).each do |uploaded|
        @ticket.attachments.attach(uploaded)
      end
    end

    @ticket.assign_attributes(ticket_params)

    if (current_user&.agent? || current_user&.admin?) && params.dig(:ticket, :approval_status).present?
      approval_param = params.dig(:ticket, :approval_status).to_s
      case approval_param
      when "approved"
        begin
          @ticket.approve!(current_user)
          TicketMailer.with(ticket: @ticket).ticket_updated_email.deliver_later
          redirect_to @ticket, notice: "Ticket was successfully updated." and return
        rescue => e
          @ticket.errors.add(:base, "Could not approve ticket: #{e.message}")
          render :edit, status: :unprocessable_content and return
        end
      when "rejected"
        reason = params.dig(:ticket, :approval_reason)
        if reason.blank?
          @ticket.errors.add(:base, "Reject reason cannot be blank")
          render :edit, status: :unprocessable_content and return
        end
        begin
          @ticket.reject!(current_user, reason)
          TicketMailer.with(ticket: @ticket).ticket_updated_email.deliver_later
          redirect_to @ticket, notice: "Ticket was successfully updated." and return
        rescue => e
          @ticket.errors.add(:base, "Could not reject ticket: #{e.message}")
          render :edit, status: :unprocessable_content and return
        end
      when "pending"
        @ticket.update(approval_status: :pending, approver: nil, approval_reason: nil, approved_at: nil)
        TicketMailer.with(ticket: @ticket).ticket_updated_email.deliver_later
        redirect_to @ticket, notice: "Ticket was successfully updated." and return
      end
    end

    if @ticket.update(ticket_params)
      TicketMailer.with(ticket: @ticket).ticket_updated_email.deliver_later
      redirect_to @ticket, notice: "Ticket was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @ticket
    @ticket.destroy
    redirect_to tickets_url, notice: "Ticket deleted successfully."
  end

  def close
    authorize @ticket, :close?
    if @ticket.update(status: :resolved)
      TicketMailer.with(ticket: @ticket).ticket_updated_email.deliver_later
      redirect_to @ticket, notice: "Ticket resolved successfully."
    else
      redirect_to @ticket, alert: @ticket.errors.full_messages.to_sentence
    end
  end

  def approve
    authorize @ticket, :approve?
    begin
      @ticket.approve!(current_user)
      TicketMailer.with(ticket: @ticket).ticket_updated_email.deliver_later
      redirect_to tickets_path, notice: "Ticket approved."
    rescue => e
      redirect_to @ticket, alert: "Could not approve ticket: #{e.message}"
    end
  end

  def reject
    authorize @ticket, :reject?
    reason = params.dig(:ticket, :approval_reason) || params[:approval_reason]
    if reason.blank?
      redirect_to @ticket, alert: "Rejection reason is required."
      return
    end

    begin
      @ticket.reject!(current_user, reason)
      TicketMailer.with(ticket: @ticket).ticket_updated_email.deliver_later
      redirect_to tickets_path, notice: "Ticket rejected."
    rescue => e
      redirect_to @ticket, alert: "Could not reject ticket: #{e.message}"
    end
  end

  def assign
    authorize @ticket, :assign?
    ticket_params_raw = params[:ticket] || {}
    team_param     = ticket_params_raw[:team_id]
    assignee_param = ticket_params_raw[:assignee_id]

    updates = {}
    if ticket_params_raw.key?(:team_id)
      updates[:team_id] = team_param.presence
    end

    if ticket_params_raw.key?(:assignee_id)
      assignee_param = assignee_param.to_s.strip
      updates[:assignee_id] = assignee_param.presence
    end

    if updates.key?(:team_id) && updates[:team_id].present?
      new_team = Team.find(updates[:team_id])
      if ticket_params_raw.key?(:assignee_id)
        if updates[:assignee_id].present?
          updates[:assignee_id] = nil unless new_team.members.exists?(id: updates[:assignee_id])
        else
          updates[:assignee_id] = nil
        end
      else
        if @ticket.assignee_id.present? && !new_team.members.exists?(id: @ticket.assignee_id)
          updates[:assignee_id] = nil
        end
      end
    end

    if updates.any? && @ticket.update(updates)
      TicketMailer.with(ticket: @ticket).ticket_updated_email.deliver_later
      redirect_to @ticket, notice: "Ticket assignment updated."
    else
      message = @ticket.errors.full_messages.to_sentence.presence || "No assignment changes provided."
      redirect_to @ticket, alert: message
    end
  end

  def board
    @tickets = policy_scope(Ticket).includes(:requester, :assignee, :team).order(:priority, :created_at)
    @tickets_by_status = Ticket.statuses.keys.each_with_object({}) do |s, h|
      h[s] = @tickets.select { |t| t.status == s }
    end
  end

  def dashboard
    authorize Ticket, :index?
    team_ids = current_user.teams.select(:id)
    @tickets = Ticket.where(assignee_id: current_user.id)
                     .or(Ticket.where(team_id: team_ids))
                     .includes(:requester, :assignee, :team)
                     .order(updated_at: :desc)

    @open_tickets = @tickets.where(status: :open)
    @open_tickets_count = @open_tickets.count
    @recent_tickets = @tickets.limit(5)
    @counts_by_status = Ticket.statuses.keys.each_with_object({}) do |s, h|
      h[s] = @tickets.select { |t| t.status == s }.size
    end
    @tickets_by_status = Ticket.statuses.keys.each_with_object({}) do |s, h|
      h[s] = @tickets.select { |t| t.status == s }.first(5)
    end
  end

  def rate
    authorize @ticket if respond_to?(:policy) # Pundit; or use a specific policy method if you have one

    unless @ticket.resolved?
      redirect_to @ticket, alert: "You can only rate resolved tickets." and return
    end

    unless current_user == @ticket.requester
      redirect_to @ticket, alert: "Only the ticket requester can rate this ticket." and return
    end

    rating_params = params.require(:ticket).permit(:customer_service_rating, :customer_service_feedback)

    # Ensure integer and within 1..5 at controller level as well (defensive)
    if rating_params[:customer_service_rating].present?
      rating_params[:customer_service_rating] = rating_params[:customer_service_rating].to_i
    end

    if @ticket.update(rating_params.merge(customer_service_rated_at: Time.current))
      redirect_to @ticket, notice: "Thanks for your feedback!"
    else
      redirect_to @ticket, alert: @ticket.errors.full_messages.to_sentence
    end
  end

  def bulk_actions
    authorize Ticket, :bulk_actions?

    ids = Array(params[:ticket_ids]).map(&:to_i).uniq
    if ids.empty?
      redirect_back fallback_location: tickets_path, alert: "No tickets selected." and return
    end

    bulk_action = params[:bulk_action].to_s
    tickets = policy_scope(Ticket).where(id: ids)

    case bulk_action
    when "close"
      bulk_close_tickets(tickets)
    when "delete"
      bulk_delete_tickets(tickets)
    else
      redirect_back fallback_location: tickets_path, alert: "No bulk action selected." and return
    end
  end
  private

  def bulk_close_tickets(tickets)
    count = 0

    Ticket.transaction do
      tickets.each do |ticket|
        # reuse same semantics as your `close` action
        if ticket.update(status: :resolved)
          TicketMailer.with(ticket: ticket).ticket_updated_email.deliver_later
          count += 1
        end
      end
    end

    redirect_back fallback_location: tickets_path, notice: "#{count} ticket(s) resolved."
  rescue => e
    redirect_back fallback_location: tickets_path, alert: "Could not bulk resolve tickets: #{e.message}"
  end

  def bulk_delete_tickets(tickets)
    count = 0

    Ticket.transaction do
      tickets.each do |ticket|
        ticket.destroy!
        count += 1
      end
    end

    redirect_back fallback_location: tickets_path, notice: "#{count} ticket(s) deleted."
  rescue => e
    redirect_back fallback_location: tickets_path, alert: "Could not bulk delete tickets: #{e.message}"
  end

  # ... rest of your private methods

  def apply_filters!
    @tickets = @tickets.where(status: params[:status]) if params[:status].present?
    @tickets = @tickets.where(category: params[:category]) if params[:category].present?
    @tickets = @tickets.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
    @tickets = @tickets.where(approval_status: params[:approval_status]) if params[:approval_status].present?

    if params[:q].present?
      q = "%#{params[:q]}%"
      adapter = ActiveRecord::Base.connection.adapter_name.downcase.to_sym
      if adapter == :postgresql
        @tickets = @tickets.where("tickets.subject ILIKE :q OR tickets.description ILIKE :q", q: q)
      else
        @tickets = @tickets.where("LOWER(tickets.subject) LIKE :q OR LOWER(tickets.description) LIKE :q", q: q.downcase)
      end
    end
    apply_sort!
  end

  def apply_sort!
    sort_param = params[:sort].presence || "created_at_desc"
    @tickets = case sort_param
    when "created_at_asc" then @tickets.order(created_at: :asc)
    when "created_at_desc" then @tickets.order(created_at: :desc)
    when "priority_asc" then @tickets.order(priority: :asc, created_at: :desc)
    when "priority_desc" then @tickets.order(priority: :desc, created_at: :desc)
    when "status_asc" then @tickets.order(status: :asc, created_at: :desc)
    when "status_desc" then @tickets.order(status: :desc, created_at: :desc)
    else @tickets.order(created_at: :desc)
    end
  end

  def load_filter_options
    @status_options = Ticket.statuses.keys
    @approval_status_options = Ticket.approval_statuses.keys
    @category_options = Ticket.where.not(category: [ nil, "" ]).distinct.order(:category).pluck(:category)
    @assignee_options = User.where(id: @tickets.where.not(assignee_id: nil).select(:assignee_id).distinct)
  end

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def ticket_params
    # NOTE: Ensure your TicketPolicy#permitted_attributes includes :attachments for regular users!
    permitted = policy(@ticket).permitted_attributes
    params.require(:ticket).permit(permitted)
  end

  def next_agent_in_rotation
    scope = User.where(role: :staff)
    scope = scope.joins(:teams).where(teams: { id: @ticket.team_id }) if @ticket.team_id.present?

    agents = scope.order(:id)
    return nil if agents.empty?

    last_assigned_index = Setting.get("last_assigned_index_#{@ticket.team_id || 'all'}")

    if last_assigned_index.nil?
      index = 0
    else
      index = (last_assigned_index.to_i + 1) % agents.size
    end

    Setting.set("last_assigned_index_#{@ticket.team_id || 'all'}", index.to_s)
    agents[index]
  end

  def assign_team_based_on_category
    # Define the mapping based on your specific team names
    target_team_name = case @ticket.category
    when "Account Access", "Technical Issue"
                         "Support"
    when "Feature Request"
                         "Ops"
    else
                         nil # No default assignment for unknown categories
    end

    if target_team_name.present?
      # Find the team by name (using case-insensitive search to be safe)
      team = Team.where("LOWER(name) = ?", target_team_name.downcase).first
      @ticket.team = team if team
    end
  end
end
