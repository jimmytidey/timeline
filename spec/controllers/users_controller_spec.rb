require 'spec_helper'

describe UsersController do

  before :each do
    RPXNow.expects(:user_data).with("123456").returns({:email => 'rpxuser@email.com',:identifier => 'test',:username => 'rpxusername'})
    @credentials = ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'SeaMonster1000bc')
    @request.env['HTTP_AUTHORIZATION'] = @credentials
  end

  def invalidate_credentials
    @request.env['HTTP_AUTHORIZATION'] = ''
  end

  describe "index and show are admin only" do

    it "should be forbidden" do
      invalidate_credentials
      get 'index'
      response.status.should == 401 # Forbidden
    end

    it "should be forbidden" do
      invalidate_credentials
      get 'show', :id => 1
      response.status.should == 401 # Forbidden
    end

    it "index should be accessable with a password" do
      get 'index'
      response.should be_success
    end

    it "show should be accessable with a password" do
      user = User.new
      User.expects(:find).with(1).returns(user)
      get 'show', :id => 1
      response.should be_success
    end
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
