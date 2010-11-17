require File.dirname(__FILE__) + '/../spec_helper'

describe TimelineChart do

  %w(title start_date end_date zoom).each do |attrib|
    it "should validates presence of #{attrib}" do
      tc = TimelineChart.make( attrib.to_sym => nil )
      tc.should_not be_valid
    end
  end

  it "should validate start date is not after the end date" do
    tc = TimelineChart.make(:start_date => Time.now, :end_date => Time.now - 1.year)
    tc.save
    tc.should_not be_valid
  end

  it "should not be possible to set a start date with year 0000" do
    tc = TimelineChart.make(:start_date => (DateTime.parse '0000/01/01'), :end_date => Time.now)
    tc.save
    tc.should_not be_valid
  end

  it "should not be possible to set a end date with year 0000" do
    tc = TimelineChart.make(:start_date => (Time.now - 2200.years), :end_date => (DateTime.parse '0000/01/01'))
    tc.save
    tc.should_not be_valid
  end
  
  it "should never return non 'private' charts in the 'top  charts' list" do
    tc = TimelineChart.make(:private => false);
    tc.save
    @top = TimelineChart.top_charts(100)
    @top.all.should be_include(tc)
  end

  it "should never return 'private' charts in the 'top  charts' list" do
    tc = TimelineChart.make(:private => true);
    tc.save
    @top = TimelineChart.top_charts(100)
    @top.all.should_not be_include(tc)
  end

  it "should increment the hit counter if viewed by a guest" do
    user = User.first
    tc = user.timeline_charts.first
    before = tc.hits
    tc.increment_hits(nil)
    after = tc.hits
    after.should == (before + 1)
  end

  it "should not increment the hit counter if viewed by the charts owner" do
    user = User.first
    tc = user.timeline_charts.first
    before = tc.hits
    tc.increment_hits(user)
    after = tc.hits
    after.should == before
  end

  it "should count its events" do
    TimelineChart.make.num_events.should == 2
  end
  
  it "should forbid a non-owner from viewing a private chart" do
    tc = TimelineChart.make(:private => true)
    user = User.make(:id => 999)
    tc.should be_forbidden(user)
  end

  it "should forbid a guest from viewing a private chart" do
    tc = TimelineChart.make(:private => true)
    tc.should be_forbidden(nil)
  end

  it "should allow the owner to view their own private chart" do
    tc = TimelineChart.make(:private => true)
    tc.should_not be_forbidden(tc.user)
  end

  it "should allow an admin to view someone else chart" do
    tc = TimelineChart.make(:private => true)
    user = User.make(:id => 999, :admin => true)
    tc.should_not be_forbidden(user)
  end
end
