require 'spec_helper'

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
end
