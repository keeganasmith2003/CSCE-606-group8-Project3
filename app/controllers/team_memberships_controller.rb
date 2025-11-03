# app/controllers/team_memberships_controller.rb
class TeamMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team

  def create
    authorize TeamMembership
    membership = @team.team_memberships.new(team_membership_params)
    if membership.save
      redirect_to @team, notice: "Member added."
    else
      redirect_to @team, alert: membership.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize TeamMembership
    membership = @team.team_memberships.find(params[:id])
    membership.destroy
    redirect_to @team, notice: "Member removed."
  end

  private
  def set_team = @team = Team.find(params[:team_id])
  def team_membership_params = params.require(:team_membership).permit(:user_id, :role)
end
