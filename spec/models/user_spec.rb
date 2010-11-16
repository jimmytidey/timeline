require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  it "should respond with name when to_s is called" do
    User.make(:name => 'foo').to_s.should == 'foo'
  end

  it "should delete associated timeline_charts and events" do
    unless user = User.find_by_identifier("123456789testy@westy.woo") then
      user = User.make!(:identifier => "123456789testy@westy.woo")
    end
    tcid = user.timeline_charts.first.id
    evid = user.timeline_charts.first.events.first.id
    user.destroy # this gets rolled back when autotest-ing, but behavior is differnt when rake-ing
    lambda{ TimelineChart.find(tcid) }.should raise_error(ActiveRecord::RecordNotFound)
    lambda{ Event.find(evid) }.should raise_error(ActiveRecord::RecordNotFound)
  end
end
