class TimelineChart < ActiveRecord::Base
  PERIOD = { :Month => 6, :Year => 7, :Decade => 8, :Century => 9 }

  belongs_to :user
  has_many :events

  attr_accessible :user_id, :title, :start_date, :end_date, :zoom, :private

  before_validation :check_dates

  validates_presence_of :title
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :user_id
  validates_presence_of :zoom
  validates_numericality_of :user_id

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
  
  def self.top_charts(num)
    self.where(["private = ?", false]).order("hits DESC").limit(20)
  end
end

