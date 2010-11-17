class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]
  before_filter :verify_authenticated_as_admin, :only => [:index, :show, :update]

  def index
    #User is authenticacted, but protect against SQL injection just incase
    sort_field = case params[:sort_by]
      #when "id" then "id"
      when "name" then "name ASC"
      when "email" then "email ASC"
      when "created" then "created_at DESC"
      else "id ASC"
    end
    @users = User.paginate :page => params[:page], :order => "#{sort_field}"
  end

  def create
    #Note that RPXNow.popup will post to users and hit this action, bypassing the 'new' action
    if data = RPXNow.user_data(params[:token])
      data = {:name => data[:username], :email => data[:email], :identifier => data[:identifier]}
      self.current_user = User.find_by_identifier(data[:identifier]) || User.create!(data)
      flash[:notice] = 'Signed in successfully'
      if params[:forward] == 'new_timeline' #if user logged in after clicking 'Add a timeline' on the home page as opposed to clicking 'Sign In' ...
        redirect_to url_for :controller => 'timeline_charts', :action => 'new'
      else
        redirect_to '/'
      end
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
  end
end
