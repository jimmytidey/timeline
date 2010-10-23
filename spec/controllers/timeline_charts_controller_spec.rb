require File.dirname(__FILE__) + '/../spec_helper'

describe TimelineChartsController do
  
  before :each do
    #TimelineChart.expects(:find).with(1).returns('PretendTC1')
  end

  it "only owner can edit timeline chart" do
    # TODO
    get 'edit', :id => 1

    response.should be_success
  end

  
end
