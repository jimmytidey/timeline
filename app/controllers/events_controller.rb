class EventsController < ApplicationController

  def create
    @timeline_chart = TimelineChart.find(params[:event][:timeline_chart_id])
    
    @event = Event.new()
	
    if @event.update_attributes(params[:event])	
      render 'create_succeeded'
    else
      render 'create_failed'
    end
  end
  
  def edit
    @event = Event.find(params[:id])
    @timeline_chart = @event.timeline_chart

    respond_to do |format|
      format.js { render 'edit' }
      format.html { render 'edit' }
    end
  end

  def update
    @event = Event.find(params[:id])
    @timeline_chart = @event.timeline_chart
    if @event.update_attributes(params[:event])
      render 'edit_succeeded'
    else
      # Re-render to ensure errors get passed
      render :controller => 'timeline_charts', :action => 'edit', :id => @timeline_chart.id
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @timeline_chart = @event.timeline_chart
    @event.destroy
    render 'delete_succeeded'
  end
end
