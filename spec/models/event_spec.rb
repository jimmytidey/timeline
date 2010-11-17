require File.dirname(__FILE__) + '/../spec_helper'

describe Event do

  %w(title start_date end_date timeline_chart_id).each do |attrib|
    it "should validates presence of #{attrib}" do
      @event = Event.make( attrib.to_sym => '' )
      @event.save
      @event.should_not be_valid
    end
  end

  it "should validate start date is not after the end date" do
    @event = Event.make(:start_date => Time.now, :end_date => Time.now - 1.year)
    @event.save
    @event.should_not be_valid
  end

  it "should not be possible to set a start date with year 0000" do
    @event = Event.make(:start_date => (DateTime.parse '0000/01/01'), :end_date => Time.now)
    @event.save
    @event.should_not be_valid
  end

  it "should not be possible to set a end date with year 0000" do
    @event = Event.make(:start_date => (Time.now - 2200.years), :end_date => (DateTime.parse '0000/01/01'))
    @event.save
    @event.should_not be_valid
  end
  
  it "should mark it's timeline as updated when modified / created" do
    ee = Event.first
    tc = ee.timeline_chart
    time = Time.parse("1999/02/03")
    tc.updated_at = time
    tc.save

    ee.title = "Big Bongo Competetion"
    ee.save
    
    tc.updated_at.should_not eql(time)
  end
end
