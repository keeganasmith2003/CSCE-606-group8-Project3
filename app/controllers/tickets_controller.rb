class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket, only: %i[show edit update destroy assign close approve reject]

  def index
    @tickets = policy_scope(Ticket)
    @tickets = @tickets.where(status: params[:status]) if params[:status].present?
    @tickets = @tickets.where(category: params[:category]) if params[:category].present?
    @tickets = @tickets.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
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
          redirect_to @ticket, notice: "Ticket was successfully updated." and return
        rescue => e
          @ticket.errors.add(:base, "Could not approve ticket: #{e.message}")
          render :edit, status: :unprocessable_content and return
        end
      when "rejected"
        reason = params.dig(:ticket, :approval_reason)
        if reason.blank?
          # Provide a clearer, user-friendly message when staff attempt to reject without a reason
          # Add as a base error so the message is shown verbatim (not prefixed by the attribute name).
          @ticket.errors.add(:base, "Reject reason cannot be blank")
          render :edit, status: :unprocessable_content and return
        end
        begin
          @ticket.reject!(current_user, reason)
          redirect_to @ticket, notice: "Ticket was successfully updated." and return
        rescue => e
          @ticket.errors.add(:base, "Could not reject ticket: #{e.message}")
          render :edit, status: :unprocessable_content and return
        end
      when "pending"
        # reset approval fields
        @ticket.update(approval_status: :pending, approver: nil, approval_reason: nil, approved_at: nil)
        redirect_to @ticket, notice: "Ticket was successfully updated." and return
      end
    end

    if @ticket.update(ticket_params)
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
      redirect_to @ticket, notice: "Ticket resolved successfully."
    else
      redirect_to @ticket, alert: @ticket.errors.full_messages.to_sentence
    end
  end

  def approve
    authorize @ticket, :approve?
    begin
      @ticket.approve!(current_user)
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
      redirect_to tickets_path, notice: "Ticket rejected."
    rescue => e
      redirect_to @ticket, alert: "Could not reject ticket: #{e.message}"
    end
  end

  def assign
    authorize @ticket, :assign?

    # Raw params
    team_param     = params.dig(:ticket, :team_id)
    assignee_param = params.dig(:ticket, :assignee_id)

    updates = {}

    # Apply team if the key is present (even when blank)
    if params[:ticket].key?(:team_id)
      updates[:team_id] = team_param.presence # "" -> nil
    end

    # Apply assignee if the key is present (even when blank)
    if params[:ticket].key?(:assignee_id)
      updates[:assignee_id] = assignee_param.presence # "" -> nil
    end

    # If team is changing but caller didn't include assignee_id,
    # and current assignee doesn't belong to the new team, clear it to pass validation.
    if updates.key?(:team_id) && updates[:team_id].present? && !params[:ticket].key?(:assignee_id)
      new_team = Team.find(updates[:team_id])
      if @ticket.assignee_id.present? && !new_team.members.exists?(id: @ticket.assignee_id)
        updates[:assignee_id] = nil
      end
    end

    if updates.any? && @ticket.update(updates)
      redirect_to @ticket, notice: "Ticket assignment updated."
    else
      # Show why it failed (e.g., "Assignee must belong to the selected team")
      message = @ticket.errors.full_messages.to_sentence.presence || "No assignment changes provided."
      redirect_to @ticket, alert: message
    end
  end


  private

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
