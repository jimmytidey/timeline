require File.dirname(__FILE__) + '/../spec_helper'

describe TimelineChart do

  %w(title start_date end_date granularity).each do |attrib|
    it "should validates presence of #{attrib}" do
      @timeline_chart = TimelineChart.make( attrib.to_sym => nil )
      @timeline_chart.should_not be_valid
    end
  end

  it "should validate start date is not after the end date" do
    @timeline_chart = TimelineChart.make(:start_date => Time.now, :end_date => Time.now - 1.year)
    @timeline_chart.save
    @timeline_chart.should_not be_valid
  end
end
