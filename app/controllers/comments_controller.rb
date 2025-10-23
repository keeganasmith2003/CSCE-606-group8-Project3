class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket

  def create
    @comment = @ticket.comments.build(comment_params)
    @comment.author = current_user
    enforce_visibility!

    authorize @comment

    if @comment.save
      redirect_to @ticket, notice: "Comment added successfully."
    else
      flash[:alert] = @comment.errors.full_messages.to_sentence
      redirect_to @ticket, status: :unprocessable_entity
    end
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:ticket_id])
  end

  def comment_params
    params.require(:comment).permit(:body, :visibility)
  end

  def enforce_visibility!
    return unless current_user.requester?

    @comment.visibility = "public"
  end
end
