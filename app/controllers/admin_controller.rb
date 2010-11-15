class AdminController < ApplicationController
  before_filter :verify_authenticated

  def verify_authenticated
    unless admin?
      render :file => 'public/401.html', :status => 401
    end
  end

  def index
    @charts = TimelineChart.paginate :page => params[:page], :order => 'created_at DESC'
  end

end
