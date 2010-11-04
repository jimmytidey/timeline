class Event < ActiveRecord::Base
  belongs_to :timeline_chart

  attr_accessible :title, :start_date, :end_date, :timeline_chart_id 

  before_validation :check_dates

  validates_presence_of :title
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :timeline_chart_id

  def check_dates
    if start_date.respond_to? '>' then
      begin
        errors[:base] << "The start date can not be before the end date." if start_date > end_date
      rescue ArgumentError
        #End date is probably nil, let validations catch this.
      end
    end
  end
end
