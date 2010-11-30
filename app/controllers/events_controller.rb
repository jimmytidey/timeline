class EventsController < ApplicationController

  def create
    @event = Event.new(params[:event])
    @timeline_chart = @event.timeline_chart
    
    begin
      @event.start_date = Date.parse(params[:event]['start_date'])
      @event.end_date = Date.parse(params[:event]['end_date'])
    rescue
      @event.start_date = Date.parse('1/1/' + params[:event]['start_date'])
      @event.end_date = Date.parse('1/1/' + params[:event]['end_date'])
    end

    if @event.save
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
    params[:event]['start_date'] = Date.parse('1/1/' + params[:event]['start_date'])
    params[:event]['end_date'] = Date.parse('1/1/' + params[:event]['end_date']) 
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
