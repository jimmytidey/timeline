class UsersController < AdminController
  skip_before_filter :verify_authenticity_token, :only => [:create]
  before_filter :authenticate, :only => [:index, :show]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    #Note that RPXNow.popup will post to users and hit this action, bypassing the 'new' action
    if data = RPXNow.user_data(params[:token])
      data = {:name => data[:username], :email => data[:email], :identifier => data[:identifier]}
      self.current_user = User.find_by_identifier(data[:identifier]) || User.create!(data)
      flash[:notice] = 'Signed in successfully'
      if params[:forward] == 'new_timeline'
        redirect_to url_for :controller => 'timeline_charts', :action => 'new'
      else
        redirect_to '/'
      end
    else
      flash[:error] = :default
      redirect_to '/'
    end
  end

  def destroy
    self.current_user = nil
    redirect_to '/'
  end
  
end
