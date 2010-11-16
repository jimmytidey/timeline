class AdminController < ApplicationController
  before_filter :verify_authenticated

  def verify_authenticated
    unless admin?
      render :file => 'public/401.html', :status => 401
    end
  end

  def index
    #User is authenticacted, but protect against SQL injection just incase
    sort_field = case params[:sort_by]
      #when "hits" then "hits"
      when "created" then "created_at"
      when "edited" then "you_cant_sort_this_with_an_'order_by'_clause"
      else "hits"
    end

    unless sort_field == "you_cant_sort_this_with_an_'order_by'_clause" then
      @charts = TimelineChart.paginate :page => params[:page], :order => "#{sort_field} DESC"
    else
      @charts = TimelineChart.all.sort!.paginate
    end
  end

end
