class TimelineChartsController < ApplicationController
  before_filter :verify_permission, :only => ['edit', 'update', 'destroy']
  
  def show
    @timeline_chart = TimelineChart.find(params[:id])
    if @timeline_chart.forbidden?(current_user)
      flash[:error] = "That timeline chart is private."
      render :file => 'public/401.html', :status => 401
    end
    @timeline_chart.increment_hits(current_user)
  end
  
  def edit
    @timeline_chart = TimelineChart.find(params[:id])
    @event = Event.new
  end
  
  def update
    params['timeline_chart'].delete('center_year') if params['timeline_chart']['center_year'] == ''
    @timeline_chart = TimelineChart.find(params[:id])
    if @timeline_chart.update_attributes(params[:timeline_chart])
      render 'edit_succeeded'
    else
      render 'edit_failed'
    end
  end
  
  def new
    create
  end
  
  def create
    params = TimelineChart::TEMPLATE
    params[:user_id]= current_user.id
    @timeline_chart = TimelineChart.new(params)

    if @timeline_chart.save
      flash[:notice] = "Now add some events to your timeline."
      redirect_to edit_timeline_chart_url(@timeline_chart)
    else
      flash[:error] = "Could not create timeline chart."
      redirect_to '/'
    end
  end

  def destroy
    @timeline_chart = TimelineChart.find(params[:id])
    @timeline_chart.destroy
    render 'destroy_succeeded'
  end

  def verify_permission
    @timeline_chart = TimelineChart.find(params[:id])
    if current_user.nil? || (@timeline_chart.user_id != current_user.id && !admin?)
      respond_to do |format|
        format.js { render 'modify_failed' }
        format.html { render :file => 'public/401.html', :status => 401 }
      end
    end
  end
end
