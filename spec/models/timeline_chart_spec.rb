require File.dirname(__FILE__) + '/../spec_helper'

describe TimelineChart do

  %w(title zoom).each do |attrib|
    it "should validates presence of #{attrib}" do
      tc = TimelineChart.make( attrib.to_sym => nil )
      tc.should_not be_valid
    end
  end

  it "should return a center_year when center_date is set" do
    tc = TimelineChart.make(:center_date => (DateTime.parse '1000/01/01'))
    tc.center_year.should == 1000
  end
  
  it "should infer the center_year when its not set" do
    tc = TimelineChart.make!(:center_date => nil)
    ev1 = tc.events.first
    ev1.start_date = Date.civil(1900)
    ev1.end_date = Date.civil(1910)
    ev1.save
    ev2 = tc.events.second
    ev2.start_date = Date.civil(1964)
    ev2.end_date = Date.civil(2000)
    ev2.save
    
    tc.center_year.should == 1950
  end
  
  it "should return the current year for a brand new chart" do
    tc = TimelineChart.make(:empty)
    tc.center_year.should == Time.now.year
  end

  it "should return non 'private' charts in the 'top  charts' list" do
    tc = TimelineChart.make(:private => false, :hits => 999);
    tc.save!
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

  it "should allow an admin to view someone else's chart" do
    tc = TimelineChart.make(:private => true)
    user = User.make(:id => 999, :admin => true)
    tc.should_not be_forbidden(user)
  end
end
