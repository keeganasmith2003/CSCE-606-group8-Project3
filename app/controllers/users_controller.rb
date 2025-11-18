class UsersController < ApplicationController
  before_action :require_login
  # sysadmin-only actions; allow index/show/profile for regular users
  before_action :require_sysadmin, except: [ :index, :show, :profile ]
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = User.order(:id)
  end

  def show; end

  # Show current user's profile
  def profile
    @user = current_user
    if @user.nil?
      redirect_to login_path, alert: "Please sign in."
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: "User created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "User updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: "User deleted."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  # Only sysadmins may set role; everyone else (not that they can reach here) gets role filtered out.
  def user_params
    permitted = [
      :provider, :uid, :email, :name, :image_url,
      :access_token, :refresh_token, :access_token_expires_at
    ]
    permitted << :role if sysadmin?
    params.require(:user).permit(permitted)
  end
end
