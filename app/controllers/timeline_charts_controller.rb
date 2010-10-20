class TimelineChartsController < ApplicationController
  def show
    @timeline_chart = TimelineChart.find(params[:id])
  end
  
  def edit
    @timeline_chart = TimelineChart.find(params[:id])
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
    if @timeline_chart.save
      flash[:notice] = "Successfully created timeline chart."
      redirect_to @timeline_chart
    else
      render :action => 'new'
    end
  end

end
