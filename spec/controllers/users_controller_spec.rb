require 'spec_helper'

describe UsersController do

  before :each do
    RPXNow.stubs(:user_data).with("123456").returns({:email => 'rpxuser@email.com',:identifier => 'test',:username => 'rpxusername'})
  end

  describe "Create" do
    it "should set session up or user" do
      post :create, :token => '123456'
      @request.session[:user_id].should_not be_nil
    end
  end

  describe "DELETE 'destroy'" do
    it "should be successful" do
      delete 'destroy', :id => 1
      response.should redirect_to(root_url)
    end

    it "should remove the user session" do
      post :create, :token => "123456"
      delete 'destroy', :id => @request.session[:user_id]
      @request.session[:user_id].should be_nil
    end
  end

end
