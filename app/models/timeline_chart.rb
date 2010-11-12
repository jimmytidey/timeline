class TimelineChart < ActiveRecord::Base
  PERIOD = { :Month => 6, :Year => 7, :Decade => 8, :Century => 9 }
  TEMPLATE = { :title => 'Untitled',  
               "start_date(1i)"=>"0100", "start_date(2i)"=>"1", "start_date(3i)"=>"1",
               "end_date(1i)"=>"2100", "end_date(2i)"=>"1", "end_date(3i)"=>"1",
               :hits => 0,
               :zoom => PERIOD[:Decade],
               :private => false }

  belongs_to :user
  has_many :events

  attr_accessible :user_id, :title, :start_date, :end_date, :zoom, :private, :hits

  before_validation :check_dates

  validates_presence_of :title
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :user_id
  validates_presence_of :hits
  validates_presence_of :zoom
  validates_numericality_of :user_id
  
  def self.top_charts(num)
    self.where(["private = ?", false]).order("hits DESC").limit(20)
  end

  def forbidden?(current_user)
    self.private? && self.user != current_user
  end

  def increment_hits(current_user)
    if self.user != current_user then
      self.hits += 1
      self.save
    end
  end

  protected
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

end

