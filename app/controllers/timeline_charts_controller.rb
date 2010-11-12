class TimelineChartsController < ApplicationController
  before_filter :verify_owner, :only => ['edit', 'update', 'destroy']
  
  def show
    @timeline_chart = TimelineChart.find(params[:id])
    if @timeline_chart.forbidden?(current_user)
      flash[:notice] = "This timeline chart is private."
      redirect_to '/'
    end
    @timeline_chart.increment_hits(current_user)
  end
  
  def edit
    @timeline_chart = TimelineChart.find(params[:id])
    @event = Event.new
  end
  
  def update
    @timeline_chart = TimelineChart.find(params[:id])
      @timeline_chart.start_date = Date.parse('1/1/' + params[:timeline_chart]['start_year'])
      @timeline_chart.end_date = Date.parse('1/1/' + params[:timeline_chart]['end_year'])
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

    logger.debug(pp @timeline_chart)
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

  def verify_owner
    @timeline_chart = TimelineChart.find(params[:id])
    if current_user.nil? || @timeline_chart.user_id != current_user.id
      respond_to do |format|
        format.js { render 'modify_failed' }
        format.html { render :file => 'public/401.html', :status => 401 }
      end
    end
  end
end
