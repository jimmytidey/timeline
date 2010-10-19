require File.dirname(__FILE__) + '/../spec_helper'

describe TimelineChart do
  it "should be valid" do
    TimelineChart.new.should be_valid
  end
end
