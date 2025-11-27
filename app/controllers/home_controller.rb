class HomeController < ApplicationController
  def index
    # If the user is signed in, redirect them to their dashboard as the landing page
    if current_user
      redirect_to dashboard_path
    end
  end
end
