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

  describe "show" do
    it "should not be acessible to a guest" do
      UsersController.any_instance.stubs(:current_user).returns(nil)
      get :show, :id => 1
      response.status.should eql(401)
      response.should render_template("public/401.html")
    end

    it "should not be acessible to a non-admin user" do
      UsersController.any_instance.stubs(:current_user).returns(User.make)
      get :show, :id => 1
      response.status.should eql(401)
      response.should render_template("public/401.html")
    end

    it "should be acessible to an admin" do
      user = User.make(:id => 676, :admin => true)
      UsersController.any_instance.stubs(:current_user).returns(user)
      User.stubs(:find).with(user.id).returns(user)
      get :show, :id => user.id
      response.should_not render_template("public/401.html")
    end
  end

  describe "update" do
    it "should not be acessible to a guest" do
      UsersController.any_instance.stubs(:current_user).returns(nil)
      get :update, :id => 1
      response.status.should eql(401)
      response.should render_template("public/401.html")
    end

    it "should not be acessible to a non-admin user" do
      UsersController.any_instance.stubs(:current_user).returns(User.make(:id => 123))
      get :update, :id => 123
      response.status.should eql(401)
      response.should render_template("public/401.html")
    end

    it "should be acessible to an admin" do
      user = User.make(:id => 321, :admin => true)
      UsersController.any_instance.stubs(:current_user).returns(user)
      User.stubs(:find).with(user.id).returns(user)
      get :update, :id => 321
      response.should_not render_template("public/401.html")
    end
  end

  describe "index" do
    it "should not be acessible to a guest" do
      UsersController.any_instance.stubs(:current_user).returns(nil)
      get :index
      response.status.should eql(401)
      response.should render_template("public/401.html")
    end

    it "should not be acessible to a non-admin user" do
      UsersController.any_instance.stubs(:current_user).returns(User.make)
      get :index
      response.status.should eql(401)
      response.should render_template("public/401.html")
    end

    it "should be acessible to an admin" do
      UsersController.any_instance.stubs(:current_user).returns(User.make(:admin => true))
      get :index
      response.should_not render_template("public/401.html")
    end
  end
end
