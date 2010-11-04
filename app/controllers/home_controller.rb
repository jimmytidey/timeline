class HomeController < ApplicationController
  protect_from_forgery :only => [:create, :update, :destroy] 

  def index  
    if current_user
      @timeline_charts = current_user.timeline_charts
    end
  end

  def new #'Add a new timeline' renders javascript to check if user is logged in.
    render 'new.js.erb'
  end
end
