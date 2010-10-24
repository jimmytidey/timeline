class EventsController < ApplicationController
  def new
    @event = Event.new
  end
  
  def create
    @event = Event.new(params[:event])
    @event.start_date = Date.parse('1/1/' + params[:event]['start_date'])
    @event.end_date = Date.parse('1/1/' + params[:event]['end_date'])

    if @event.save
      flash[:notice] = "Successfully created event."
      redirect_to root_url
    else
      render :action => 'new'
    end
  end
  
  def edit
    @event = Event.find(params[:id])
  end
  
  def update
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      flash[:notice] = "Successfully updated event."
      redirect_to root_url
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    flash[:notice] = "Successfully destroyed event."
    redirect_to root_url
  end
end
