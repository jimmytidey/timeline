class TimelineChart < ActiveRecord::Base
  belongs_to :user
  has_many :events
  attr_accessible :user_id, :title, :start_date, :end_date
  before_validation { self.user_id = self.id.to_i }

  validates_presence_of :title
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :user_id
  validates_presence_of :granularity
  validates_numericality_of :user_id
  
end
