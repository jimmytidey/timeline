class HomeController < ApplicationController
  protect_from_forgery :only => [:create, :update, :destroy] 

  def index 
    logger.fatal( "  **********************  " )
    logger.fatal( url_for(:controller => :users, :action => :create, :only_path => false, :forward => 'new_timeline') )
    logger.fatal( "  **********************  " )
    @top_charts = TimelineChart.top_charts(20)
    if current_user
      @user_charts  = current_user.timeline_charts
    end
  end

  def new #'Add a new timeline' renders javascript to check if user is logged in.
    render 'new.js.erb'
  end
end
