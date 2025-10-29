class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include Pundit::Authorization
  helper_method :current_user

  unless Rails.env.test?
    rescue_from Pundit::NotAuthorizedError do
      respond_to do |format|
        format.html { redirect_to(request.referrer.presence || root_path, alert: "Not authorized.") }
        format.json { render json: { error: "Forbidden" }, status: :forbidden }
      end
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def authenticate_user!
    redirect_to login_path, alert: "Please sign in." unless current_user
  end

  def sysadmin?
    current_user&.sysadmin?
  end

  def require_sysadmin
    return if sysadmin?
    # You can also `head :forbidden` for APIs; redirect is nicer for HTML.
    redirect_to root_path, alert: "Not authorized."
  end

  def require_login
    return if current_user

    # For HTML, remember where they were going (GET only) and redirect to login
    if request.format.html?
      session[:return_to] = request.get? ? request.fullpath : root_path
      redirect_to login_path, alert: "Please sign in."
    else
      # For JSON/API
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
