require File.dirname(__FILE__) + '/../spec_helper'

describe TimelineChart do

  %w(title start_date end_date granularity).each do |attrib|
    it "should validates presence of #{attrib}" do
      @timeline_chart = TimelineChart.make( attrib.to_sym => nil )
      @timeline_chart.should_not be_valid
    end
  end
end
