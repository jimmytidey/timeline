class AdminsController < ApplicationController
  before_filter :verify_authenticated_as_admin

  def index
    #User is authenticacted, but protect against SQL injection just incase
    sort_field = case params[:sort_by]
      when "created" then "created_at"
      when "edited" then "updated_at"
      else "hits"
    end
    @charts = TimelineChart.paginate :page => params[:page], :order => "#{sort_field} DESC"
  end
  
  def update
    @timeline_chart = TimelineChart.find(params["id"])
    @timeline_chart.hits = params["timeline_chart"]["hits"]
    @timeline_chart.save!
    redirect_to admins_url
  end
end
