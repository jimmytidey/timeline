class User < ActiveRecord::Base
  has_many :timeline_charts

  attr_protected :admin

  def to_s
    name
  end

end
