class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]
  before_filter :verify_authenticated_as_admin, :only => [:update]

  def index
    @user_charts  = current_user.timeline_charts
  end

  def create
    #Note that RPXNow.popup will post to users and hit this action, bypassing the 'new' action
    if data = RPXNow.user_data(params[:token])
      data = {:name => data[:username], :email => data[:email], :identifier => data[:identifier]}
      self.current_user = User.find_by_identifier(data[:identifier]) || User.create!(data)
      flash[:notice] = 'Signed in successfully'
      redirect_to user_path(current_user)
    else
      redirect_to '/'
    end
  end

  def destroy
    flash[:notice] = 'Signed out successfully'
    self.current_user = nil
    redirect_to '/'
  end
  
  def update
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_url
  end

  def show
    @user = User.find(params[:id])
    @user_charts  = current_user.timeline_charts
  end
end
