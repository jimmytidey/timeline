class TimelineChartsController < ApplicationController
  before_filter :verify_owner, :only => ['edit', 'update', 'destroy']
  
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
      render 'edit_succeeded'
    else
      render 'edit_failed'
    end
  end
  
  def new
    params[:timeline_chart] = { :title => 'Untitled',  
      "start_date(1i)"=>"1800", "start_date(2i)"=>"1", "start_date(3i)"=>"1", 
      "end_date(1i)"=>"1900", "end_date(2i)"=>"1", "end_date(3i)"=>"1" }
    create
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

  def destroy
    @timeline_chart = TimelineChart.find(params[:id])
    @timeline_chart.destroy
    render 'destroy_succeeded'
  end

  def verify_owner
    @timeline_chart = TimelineChart.find(params[:id])
    if current_user.nil? || @timeline_chart.user_id != current_user.id
      render 'modify_failed'
    end
  end
end
