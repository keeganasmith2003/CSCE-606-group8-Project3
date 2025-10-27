class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket, only: %i[show edit update destroy assign close]

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
    @ticket = Ticket.new(ticket_params)
    @ticket.requester = current_user
    authorize @ticket

    if Setting.auto_round_robin?
      @ticket.assignee = next_agent_in_rotation
    end

    if @ticket.save
      redirect_to @ticket, notice: "Ticket was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @ticket
  end

  def update
    authorize @ticket
    if @ticket.update(ticket_params)
      redirect_to @ticket, notice: "Ticket was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @ticket
    @ticket.destroy
    redirect_to tickets_url, notice: "Ticket deleted successfully."
  end

  def close
    authorize @ticket, :close?

    if @ticket.update(status: :closed)
      redirect_to @ticket, notice: "Ticket closed successfully."
    else
      redirect_to @ticket, alert: @ticket.errors.full_messages.to_sentence
    end
  end

  def assign
    authorize @ticket, :assign?
    agent = User.find(params[:ticket][:assignee_id])
    @ticket.update(assignee: agent)
    redirect_to @ticket, notice: "Ticket assigned to #{agent.display_name}."
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:subject, :description, :status, :priority, :category, :assignee_id)
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
