class Event < ActiveRecord::Base
  attr_accessible :title, :start_date, :end_date, :timeline_chart_id 

  belongs_to :timeline_chart
  validates_presence_of :title
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :timeline_chart_id
end
