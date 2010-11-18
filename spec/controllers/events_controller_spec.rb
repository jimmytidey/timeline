require File.dirname(__FILE__) + '/../spec_helper'

describe EventsController do

  before :each do
    @timeline_chart = TimelineChart.make
  end

  it "create action should render correct rjs when model is valid" do
    Event.any_instance.stubs(:save).returns(true)
    Event.any_instance.stubs(:timeline_chart).returns(1)
    xhr :post, :create, :event => {:title => 'Birth', :start_date => '2000', :end_date => '2001', :timeline_chart_id => 1}
    response.should render_template 'create_succeeded'
  end
  
  it "create action should render correct rjs when model is invalid" do
    Event.any_instance.stubs(:save).returns(false)
    Event.any_instance.stubs(:timeline_chart).returns(1)
    xhr :post, :create, :event => {:title => 'Birth', :start_date => '2003', :end_date => '2001', :timeline_chart_id => 1}
    response.should render_template 'create_failed'
  end

  it "edit action should render edit template" do
    Event.stubs(:find).with(1).returns(Event.make)
    get :edit, :id => 1 #Event.make.id
    response.should render_template(:edit)
  end
  
  it "update action should render correct rjs when model is valid" do
    Event.stubs(:find).with(111).returns(Event.make(:id => 111))
    Event.any_instance.stubs(:timeline_chart).returns(TimelineChart.make)
    Event.any_instance.stubs(:update_attributes).returns(true)
    xhr :put, :update, :id => 111, :event => {:title => 'Birth', :start_date => '2000', :end_date => '2001', :timeline_chart_id => 222}
    response.should render_template 'edit_succeeded'
  end
  
  it "update action should render correct rjs when model is invalid" do
    Event.stubs(:find).with(111).returns(Event.make(:id => 111))
    Event.any_instance.stubs(:timeline_chart).returns(TimelineChart.make)
    Event.any_instance.stubs(:update_attributes).returns(false)
    xhr :put, :update, :id => 111, :event => {:title => 'Birth', :start_date => '2004', :end_date => '0', :timeline_chart_id => 222}
    response.should render_template 'edit'
  end

  it "Destroy action must call destroy" do
    Event.stubs(:find).with(111).returns(Event.make(:id => 111))
    Event.any_instance.stubs(:timeline_chart).returns(TimelineChart.make)
    Event.any_instance.expects(:destroy).once
    xhr :delete, :destroy, :id => 111, :event => {:title => 'Birth', :start_date => '2004', :end_date => '0', :timeline_chart_id => 222}
    response.should render_template 'delete_succeeded'
  end
end
