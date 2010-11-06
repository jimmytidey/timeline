require File.dirname(__FILE__) + '/../spec_helper'

describe TimelineChartsController do
 
  it "Owner can destroy a timeline chart that they created" do
    TimelineChart.stubs(:find).with(1).returns(TimelineChart.make)
    TimelineChartsController.any_instance.stubs(:current_user).returns(User.make(:id => 1))
    xhr :delete, 'destroy', { :id => 1 }
    response.should render_template 'destroy_succeeded'
  end

  it "Non owner can not destroy timeline chart created by someone else" do
    TimelineChart.stubs(:find).with(1).returns(TimelineChart.make)
    TimelineChartsController.any_instance.stubs(:current_user).returns(User.make(:id => 999))
    xhr :delete, 'destroy', { :id => 1 }
    response.should render_template 'modify_failed'
  end

  it "Somebody who is not logged in can not destroy a timeline chart" do
    TimelineChart.stubs(:find).with(1).returns(TimelineChart.make)
    TimelineChartsController.any_instance.stubs(:current_user).returns(nil)
    xhr :delete, 'destroy', { :id => 1 }
    response.should render_template 'modify_failed'
  end

  it "Owner can edit a timeline chart that they have created" do
    TimelineChart.stubs(:find).with(1).returns(TimelineChart.make)
    TimelineChartsController.any_instance.stubs(:current_user).returns(User.make(:id => 1))
    get :edit, { :id => 1 }
    response.should render_template 'edit'
  end

  it "Owner can not edit a timeline chart that they have not created" do
    TimelineChart.stubs(:find).with(1).returns(TimelineChart.make)
    TimelineChartsController.any_instance.stubs(:current_user).returns(User.make(:id => 999))
    get :edit, { :id => 1 }
    response.should render_template '401'
  end
end
