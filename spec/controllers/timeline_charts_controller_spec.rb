require File.dirname(__FILE__) + '/../spec_helper'

describe TimelineChartsController do
 
  it "Non owner can not destroy timeline chart" do
    TimelineChart.stubs(:find).with(1).returns(TimelineChart.make)
    TimelineChart.stubs(:update_attributes).returns(true)
    self.stubs(:current_user).returns(User.make(:id => 999))
    xhr :delete, timeline_chart_url(1)
    response.should render_template 'destroy_failed'
  end
end
