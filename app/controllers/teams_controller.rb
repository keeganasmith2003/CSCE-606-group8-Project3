class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy]

  def index
    @teams = policy_scope(Team).order(:name)
  end

  def show
    authorize @team
    @memberships = @team.team_memberships.includes(:user).order(created_at: :asc)
  end

  def new
    @team = Team.new
    authorize @team
  end

  def create
    @team = Team.new(team_params)
    authorize @team
    if @team.save
      redirect_to @team, notice: "Team created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @team
  end

  def update
    authorize @team
    if @team.update(team_params)
      redirect_to @team, notice: "Team updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @team
    if @team.tickets.exists?
      redirect_to @team, alert: "Cannot delete a team with assigned tickets."
    else
      @team.destroy
      redirect_to teams_path, notice: "Team deleted."
    end
  end

  private
  def set_team = @team = Team.find(params[:id])
  def team_params = params.require(:team).permit(:name, :description)
end
