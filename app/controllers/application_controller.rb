class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end
  helper_method :current_user

  def current_user=(user)
    session[:user_id] = user.try(:id)
    @current_user = user
  end

  def admin?
    if current_user.nil?
      return false
    else
      return current_user.admin?
    end
  end

end
