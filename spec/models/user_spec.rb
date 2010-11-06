require 'spec_helper'

describe User do
  it "should respond with name when to_s is called" do
    User.make(:name => 'foo').to_s.should == 'foo'
  end
end
