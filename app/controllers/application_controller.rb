class ApplicationController < ActionController::Base

  helper_method :current_user

  private

  def authenticate_user!
    redirect_to login_path unless current_user
  end

  def current_user
    @current_user ||= Visitor.find(session[:user_id]) if session[:user_id]
  end
end
