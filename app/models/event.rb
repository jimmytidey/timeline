class Event < ActiveRecord::Base
  belongs_to :timeline_chart

  attr_accessible :title, :start_date, :end_date, :timeline_chart_id 

  before_validation :check_dates

  validates_presence_of :title
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :timeline_chart_id

  def check_dates
    begin
      errors[:base] << "The start date can not be before the end date." if start_date > end_date
      if start_date.year == 0 || end_date.year == 0 then
        errors[:base] << "0 is an invalid year. See http://en.wikipedia.org/wiki/0_(year) for the explanation."
      end
    rescue ArgumentError, NoMethodError
      #End date is probably not set, let validations catch this.
    end
  end

  def <=>(event)
    if self.updated_at < event.updated_at then
      1
    elsif self.updated_at > event.updated_at then
      -1
    else
      0
    end
  end
end
