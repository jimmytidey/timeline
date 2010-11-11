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

  it "should not be possible to set a start date with year 0000" do
    @timeline_chart = TimelineChart.make(:start_date => (DateTime.parse '0000/01/01'), :end_date => Time.now)
    @timeline_chart.save
    @timeline_chart.should_not be_valid
  end

  it "should not be possible to set a end date with year 0000" do
    @timeline_chart = TimelineChart.make(:start_date => (Time.now - 2200.years), :end_date => (DateTime.parse '0000/01/01'))
    @timeline_chart.save
    @timeline_chart.should_not be_valid
  end
  
  it "should never return non 'private' charts in the 'top  charts' list" do
    @timeline_chart = TimelineChart.make(:private => false);
    @timeline_chart.save
    @top = TimelineChart.top_charts(100)
    @top.all.should be_include(@timeline_chart)
  end

  it "should never reutrn 'private' charts in the 'top  charts' list" do
    @timeline_chart = TimelineChart.make(:private => true);
    @timeline_chart.save
    @top = TimelineChart.top_charts(100)
    @top.all.should_not be_include(@timeline_chart)
  end

  it "should increment the hit counter after non-owner views the timeline" do
    false.should == true
  end
end
