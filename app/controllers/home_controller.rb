class HomeController < ApplicationController
  protect_from_forgery :only => [:create, :update, :destroy] 

  def index  
  end

  def new
    render 'new'
  end
end
