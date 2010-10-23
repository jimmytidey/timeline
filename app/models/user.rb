class User < ActiveRecord::Base
  has_many :timeline_charts
  #require 'rpx_now/user_integration'
  #include RPXNow::UserIntegration

  def to_s
    name
  end

end
