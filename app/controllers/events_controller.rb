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
      #flash[:notice] = "Successfully created event."
      #redirect_to edit_timeline_chart_url(@event.timeline_chart)
      render 'add_event_ajax_success'
    else
      #flash[:error] = "The event did not save due to a problem."
      #redirect_to edit_timeline_chart_url(@event.timeline_chart)
      render 'add_event_ajax_failed'
    end
  end
  
  def edit
    @event = Event.find(params[:id])
    @timeline_chart = @event.timeline_chart
  end
  
 # Pending Jimmies descision
 # def update
 #   @event = Event.find(params[:id])
 #   @timeline_chart = @event.timeline_chart
 #   params[:event]['start_date'] = Date.parse('1/1/' + params[:event]['start_date'])
 #   params[:event]['end_date'] = Date.parse('1/1/' + params[:event]['end_date'])
 #   if @event.update_attributes(params[:event])
 #     flash[:notice] = "Successfully updated event."
 #     redirect_to edit_timeline_chart_url(@event.timeline_chart)
 #   else
 #     flash[:error] = "The event did not save due to a problem."
 #     render :controller => 'timeline_charts', :action => 'edit', :id => @timeline_chart.id
 #   end
 # end
  
  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    flash[:notice] = "Successfully destroyed event."
    redirect_to edit_timeline_chart_url(@event.timeline_chart)
  end
end
