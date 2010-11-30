class TimelineChart < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 14
  PERIOD = { :Month => 6, :Year => 7, :Decade => 8, :Century => 9 }
  TEMPLATE = { :title => 'Untitled',  
               :hits => 0,
               :zoom => PERIOD[:Decade],
               :private => false }

  belongs_to :user
  has_many :events, :dependent => :destroy

  attr_accessible :user_id, :title, :zoom, :private, :hits, :center_date

  validates_presence_of :title
  validates_presence_of :user_id
  validates_presence_of :hits
  validates_presence_of :zoom
  validates_numericality_of :user_id
  
  def center_year
    if self.events.length < 1
      return Time.now.year
    elsif center_date.nil?
      dif = end_date - start_date
      return (start_date + (dif / 2)).year
    else
      return center_date.year
    end
  end

  def start_year
    start_date && start_date.year
  end

  def end_year
    end_date && end_date.year
  end

  def start_date
    begin
      self.events.order("start_date ASC").first.start_date
    rescue NoMethodError
      nil
    end
  end

  def end_date
    begin
      self.events.order("end_date DESC").first.end_date
    rescue NoMethodError
      nil
    end
  end

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

end

