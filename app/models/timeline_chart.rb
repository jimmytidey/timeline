class TimelineChart < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 14
  PERIOD = { :Month => 6, :Year => 7, :Decade => 8, :Century => 9 }
  TEMPLATE = { :title => 'Untitled',  
               "start_date(1i)"=>"0100", "start_date(2i)"=>"1", "start_date(3i)"=>"1",
               "end_date(1i)"=>"2100", "end_date(2i)"=>"1", "end_date(3i)"=>"1",
               :hits => 0,
               :zoom => PERIOD[:Decade],
               :private => false }

  belongs_to :user
  has_many :events, :dependent => :destroy

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
    if current_user.nil? then #guest
      return self.private?
    elsif current_user.admin? then #admin
      return false
    elsif self.user == current_user #owner
      return false
    end
    self.private? #authenicated non-owner
  end

  def increment_hits(current_user)
    if self.user != current_user then
      self.hits += 1
      self.save
    end
  end

  def num_events
    self.events.length
  end

  def edited_at
    if num_events == 0
      self.updated_at
    else
      ee = self.events
      ee.sort.first.updated_at
    end
  end

  def <=>(tc)
    if self.edited_at < tc.edited_at then
      1
    elsif self.edited_at > tc.edited_at then
      -1
    else
      0
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

