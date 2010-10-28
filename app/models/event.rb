class Event < ActiveRecord::Base
  attr_accessible :title, :start_date, :end_date, :timeline_chart_id 
  before_validation :check_dates

  belongs_to :timeline_chart
  validates_presence_of :title
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :timeline_chart_id

  def check_dates
    errors[:base] << "The start date can not be before the end date." if start_date > end_date
  end
end
