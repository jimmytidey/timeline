require File.dirname(__FILE__) + '/../spec_helper'

describe TimelineChartsController do
 
  describe 'Permisions' do

    before :each do
      TimelineChart.stubs(:find).with(1).returns(TimelineChart.make)
    end

    it "Non admin can not view a timeline chart created by someone else if it's private" do
      TimelineChart.stubs(:find).with(1).returns(TimelineChart.make(:private => true))
      TimelineChartsController.any_instance.stubs(:current_user).returns(User.make(:id => 999))
      get :show, { :id => 1 }
      flash[:error].should == "That timeline chart is private."
    end

    it "Owner can destroy a timeline chart that they created" do
      TimelineChartsController.any_instance.stubs(:current_user).returns(User.make(:id => 1))
      xhr :delete, 'destroy', { :id => 1 }
      response.should render_template 'destroy_succeeded'
    end

    it "Non owner can not destroy timeline chart created by someone else" do
      TimelineChartsController.any_instance.stubs(:current_user).returns(User.make(:id => 999))
      xhr :delete, 'destroy', { :id => 1 }
      response.should render_template 'modify_failed'
    end

    it "Somebody who is not logged in can not destroy a timeline chart" do
      TimelineChartsController.any_instance.stubs(:current_user).returns(nil)
      xhr :delete, 'destroy', { :id => 1 }
      response.should render_template 'modify_failed'
    end

    it "Owner can edit a timeline that they have created" do
      TimelineChartsController.any_instance.stubs(:current_user).returns(User.make(:id => 1))
      TimelineChart.stubs(:find).with(1).returns(TimelineChart.make(:user_id => 1))
      get :edit, { :id => 1 }
      response.should render_template 'edit'
    end

    it "Owner can not edit a timeline that they have not created" do
      TimelineChartsController.any_instance.stubs(:current_user).returns(User.make(:id => 999))
      TimelineChart.stubs(:find).with(1).returns(TimelineChart.make(:user_id => 1))
      get :edit, { :id => 1 }
      response.should render_template '401'
    end

    it "Admin can edit any timeline" do
      TimelineChartsController.any_instance.stubs(:current_user).returns(User.make(:id => 999, :admin => true))
      TimelineChart.stubs(:find).with(1).returns(TimelineChart.make(:user_id => 1))
      get :edit, { :id => 1 }
      response.should render_template 'edit'
    end

    it "Admin can delete any timeline" do
      TimelineChartsController.any_instance.stubs(:current_user).returns(User.make(:id => 999, :admin => true))
      TimelineChart.stubs(:find).with(1).returns(TimelineChart.make(:user_id => 1))
      xhr :delete, 'destroy', { :id => 1 }
      response.should render_template 'destroy_succeeded'
    end
  end

  it "Provides route to show timeline 1 at 'example.com/1/untitled'" do
    assert_recognizes({ :controller => "timeline_charts", :action => "show", :id => "1", :name => "untitled" }, "/1/untitled")
  end

end
