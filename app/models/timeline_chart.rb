class TimelineChart < ActiveRecord::Base
  attr_accessible :user_id, :title, :start, :end
end
