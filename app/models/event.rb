class Event < ActiveRecord::Base
  belongs_to :timeline_chart
  validates_presence_of :title
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :timeline_chart_id
end
