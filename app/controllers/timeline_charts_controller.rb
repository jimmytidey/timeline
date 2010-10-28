class TimelineChartsController < ApplicationController
  def show
    @timeline_chart = TimelineChart.find(params[:id])
  end
  
  def edit
    @timeline_chart = TimelineChart.find(params[:id])
    @event = Event.new
  end
  
  def update
    @timeline_chart = TimelineChart.find(params[:id])
    if @timeline_chart.update_attributes(params[:timeline_chart])
      flash[:notice] = "Successfully updated timeline chart."
      redirect_to @timeline_chart
    else
      render :action => 'edit'
    end
  end
  
  def new
      @timeline_chart = TimelineChart.new
  end
  
  def create
    @timeline_chart = TimelineChart.new(params[:timeline_chart])
    @timeline_chart.granularity = 'years' # RFU 'months', 'centurys', 'years' etc
    @timeline_chart.user_id = current_user.id

    if @timeline_chart.save
      flash[:notice] = "Now add some events to your timeline."
      redirect_to edit_timeline_chart_url(@timeline_chart)
    else
      render :action => 'new'
    end
  end

end
