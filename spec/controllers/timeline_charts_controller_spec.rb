require File.dirname(__FILE__) + '/../spec_helper'

describe TimelineChartsController do
  
  before :each do
    RPXNow.expects(:user_data).with("123456").returns({:email => 'rpxuser@email.com',:identifier => 'test',:username => 'rpxusername'})
    ApplicationController.any_instance.stubs(:current_user).with().returns(User.make(:id => 32))
  end

  it "owner can not edit timeline chart" do
    tc = TimelineChart.make
    tc.save
    get 'edit', :id => tc.id
    response.should_not be_success
  end
end
