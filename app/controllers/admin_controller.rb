class AdminController < ApplicationController
  before_filter :verify_authenticated_as_admin

  def index
    #User is authenticacted, but protect against SQL injection just incase
    sort_field = case params[:sort_by]
      #when "hits" then "hits"
      when "created" then "created_at"
      when "edited" then "updated_at"
      else "hits"
    end
    @charts = TimelineChart.paginate :page => params[:page], :order => "#{sort_field} DESC"
  end

end
