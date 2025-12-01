class SessionsController < ApplicationController
  skip_forgery_protection only: :create

  # "Login" action that starts Google OAuth.
  def new
    redirect_to "/auth/google_oauth2"
  end

  # /auth/:provider/callback lands here
  def create
    auth = request.env["omniauth.auth"]
    unless auth
      redirect_to root_path, alert: "No auth data received."
      return
    end

    user = User.from_omniauth(auth)
    session[:user_id] = user.id
  # After sign-in, send users to their personal dashboard
  redirect_to personal_dashboard_path, notice: "Signed in as #{user.display_name}"
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("OAuth user save failed: #{e.message}")
    redirect_to root_path, alert: "Could not sign in."
  end

  def failure
    redirect_to root_path, alert: params[:message] || "Authentication failed."
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out."
  end
end
