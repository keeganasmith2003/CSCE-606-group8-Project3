class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket, only: %i[show edit update destroy assign close approve reject]

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
                 .or(
                   policy_scope(Ticket).where(team_id: team_ids)
                 )
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
    @ticket = Ticket.new(status: "open") # default status
    authorize @ticket
  end

  def create
    @ticket = Ticket.new
    authorize @ticket
    @ticket.assign_attributes(ticket_params)
    @ticket.requester = current_user

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
    # Allow staff/admin to remove attachments (handled before attribute update)
    if (current_user&.agent? || current_user&.admin?) && params.dig(:ticket, :remove_attachment_ids).present?
      ids = Array(params.dig(:ticket, :remove_attachment_ids)).map(&:to_i)
      @ticket.attachments.each do |att|
        att.purge if ids.include?(att.id)
      end
    end

    # Attach any uploaded files explicitly (some test drivers may not trigger attach via update)
    if (current_user&.agent? || current_user&.admin?) && params.dig(:ticket, :attachments).present?
      Array(params.dig(:ticket, :attachments)).each do |uploaded|
        @ticket.attachments.attach(uploaded)
      end
    end

    # If current user is staff/admin and approval params are present, handle approval flow
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
          # Provide a clearer, user-friendly message when staff attempt to reject without a reason
          @ticket.errors.add(:base, "Reject reason cannot be blank")
          render :edit, status: :unprocessable_content and return
        end
        begin
          @ticket.reject!(current_user, reason)
          # 2. Send email on Rejection
          TicketMailer.with(ticket: @ticket).ticket_updated_email.deliver_later

          redirect_to @ticket, notice: "Ticket was successfully updated." and return
        rescue => e
          @ticket.errors.add(:base, "Could not reject ticket: #{e.message}")
          render :edit, status: :unprocessable_content and return
        end
      when "pending"
        # reset approval fields
        @ticket.update(approval_status: :pending, approver: nil, approval_reason: nil, approved_at: nil)
        # 3. Send email on Reset to Pending
        TicketMailer.with(ticket: @ticket).ticket_updated_email.deliver_later

        redirect_to @ticket, notice: "Ticket was successfully updated." and return
      end
    end

    if @ticket.update(ticket_params)
      # 4. Send email on Standard Update
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

    # Raw params
    ticket_params_raw = params[:ticket] || {}
    team_param     = ticket_params_raw[:team_id]
    assignee_param = ticket_params_raw[:assignee_id]

    updates = {}

    # Apply team if the key is present (even when blank)
    if ticket_params_raw.key?(:team_id)
      updates[:team_id] = team_param.presence # "" -> nil
    end

    # Apply assignee if the key is present (even when blank)
    # When assignee_param is "" (from blank select option), convert to nil
    if ticket_params_raw.key?(:assignee_id)
      assignee_param = assignee_param.to_s.strip
      updates[:assignee_id] = assignee_param.presence # "" -> nil, "123" -> "123"
    end

    # If team is changing, ensure assignee is cleared when appropriate to avoid validation
    if updates.key?(:team_id) && updates[:team_id].present?
      new_team = Team.find(updates[:team_id])

      if ticket_params_raw.key?(:assignee_id)
        # If an assignee id was provided but the assignee doesn't belong to the new team, clear it.
        if updates[:assignee_id].present?
          updates[:assignee_id] = nil unless new_team.members.exists?(id: updates[:assignee_id])
        else
          # Explicit blank was provided -> ensure nil
          updates[:assignee_id] = nil
        end
      else
        # No assignee param provided: if current assignee doesn't belong to the new team, clear it.
        if @ticket.assignee_id.present? && !new_team.members.exists?(id: @ticket.assignee_id)
          updates[:assignee_id] = nil
        end
      end
    end

    if updates.any? && @ticket.update(updates)
      TicketMailer.with(ticket: @ticket).ticket_updated_email.deliver_later
      redirect_to @ticket, notice: "Ticket assignment updated."
    else
      # Show why it failed (e.g., "Assignee must belong to the selected team")
      message = @ticket.errors.full_messages.to_sentence.presence || "No assignment changes provided."
      redirect_to @ticket, alert: message
    end
  end

  # Kanban-style board view: group visible tickets by status for UI columns
  def board
    @tickets = policy_scope(Ticket).includes(:requester, :assignee, :team).order(:priority, :created_at)
    # Ensure all statuses have keys
    @tickets_by_status = Ticket.statuses.keys.each_with_object({}) do |s, h|
      h[s] = @tickets.select { |t| t.status == s }
    end
  end

  # Personal dashboard: summary of tickets assigned to current_user grouped by status
  def dashboard
    authorize Ticket, :index?

    # Show tickets assigned to the current user _or_ assigned to any of the user's teams.
    # Use direct Ticket queries (not policy_scope) because policy_scope for regular users
    # restricts to requester-only, which would hide assigned tickets.
    team_ids = current_user.teams.select(:id)
    @tickets = Ticket.where(assignee_id: current_user.id)
                     .or(Ticket.where(team_id: team_ids))
                     .includes(:requester, :assignee, :team)
                     .order(updated_at: :desc)

    @open_tickets = @tickets.where(status: :open)
    @open_tickets_count = @open_tickets.count

    # 5 most recently updated tickets
    @recent_tickets = @tickets.limit(5)

    # counts per status
    @counts_by_status = Ticket.statuses.keys.each_with_object({}) do |s, h|
      h[s] = @tickets.select { |t| t.status == s }.size
    end

    # provide a quick list for each status (limit 5)
    @tickets_by_status = Ticket.statuses.keys.each_with_object({}) do |s, h|
      h[s] = @tickets.select { |t| t.status == s }.first(5)
    end
  end


  private
  def apply_filters!
    # status: integer enum
    @tickets = @tickets.where(status: params[:status]) if params[:status].present?

    # category: string
    @tickets = @tickets.where(category: params[:category]) if params[:category].present?

    # assignee
    @tickets = @tickets.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?

    # approval_status: integer enum
    @tickets = @tickets.where(approval_status: params[:approval_status]) if params[:approval_status].present?

    # free-text search on subject + description
    if params[:q].present?
      q = "%#{params[:q]}%"
      adapter = ActiveRecord::Base.connection.adapter_name.downcase.to_sym

      if adapter == :postgresql
        # Case-insensitive search in Postgres
        @tickets = @tickets.where(
          "tickets.subject ILIKE :q OR tickets.description ILIKE :q",
          q: q
        )
      else
        @tickets = @tickets.where(
          "LOWER(tickets.subject) LIKE :q OR LOWER(tickets.description) LIKE :q",
          q: q.downcase
        )
      end
    end
  end


  def load_filter_options
    @status_options         = Ticket.statuses.keys
    @approval_status_options = Ticket.approval_statuses.keys
    @category_options       = Ticket.where.not(category: [ nil, "" ]).distinct.order(:category).pluck(:category)
    @assignee_options       = User.where(id: @tickets.where.not(assignee_id: nil).select(:assignee_id).distinct)
  end

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def ticket_params
    permitted = policy(@ticket).permitted_attributes
    params.require(:ticket).permit(permitted)
  end

  def next_agent_in_rotation
    agents = User.where(role: :staff).order(:id)
    return agents.first if agents.empty?

    last_assigned_index = Setting.get("last_assigned_index")
    if last_assigned_index.nil?
      index = 0
    else
      index = (last_assigned_index.to_i + 1) % agents.size
    end
    Setting.set("last_assigned_index", index.to_s)
    agents[index]
  end
end
