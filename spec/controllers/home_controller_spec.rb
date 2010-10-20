require 'spec_helper'

describe HomeController do

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end

    it "should be the home page" do
      { :get => "/" }.should route_to( :controller => 'home', :action => 'index')
    end
  end

  describe "new index" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end

    it "should be javascript" do
      get 'new'
      response.content_type.should eql "text/javascript"
    end
  end

end
