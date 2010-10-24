require 'spec_helper'

describe Event do

  %w(title start_date end_date timeline_chard_id).each do |attrib|
    it "should validates presence of #{attrib}" do
      @event = Event.make( attrib.to_sym => nil )
      @event.should_not be_valid
    end
  end
end
