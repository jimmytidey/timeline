class User < ActiveRecord::Base
  #require 'rpx_now/user_integration'
  #include RPXNow::UserIntegration

  def to_s
    name
  end

end
