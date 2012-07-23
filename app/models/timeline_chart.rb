class TimelineChart < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 14
  NUM_TOP_CHARTS = 5
  PERIOD = [[:Month, 6], [:Year, 7], [:Decade, 8], [:Century, 9]]
  INTERVAL = [[:One, 60], [:Two, 90], [:Three, 120], [:Four, 170], [:Five, 220]]
  TEMPLATE = { :title => 'Untitled',
               :hits => 0,
               :zoom => 8,
               :private => false }

  belongs_to :user
  has_many :events, :dependent => :destroy

  attr_accessible :user_id, :title, :interval_pixels, :zoom,  :private, :hits, :center_date, :center_year, :description
	
  scope :top, where(["private = ?", false]).order("hits DESC").limit(NUM_TOP_CHARTS)
  
  validates_presence_of :title
  validates_presence_of :user_id
  validates_presence_of :hits
  validates_presence_of :zoom
  validates_numericality_of :user_id

  def center_year
    if self.events.length < 1
      Time.now.year
    elsif center_date.nil?
      dif = end_date - start_date
      (start_date + (dif / 2)).year
    else
      center_date.year
    end
  end

  def center_year=(year)
    if year == "" 
      self.center_date = nil
    elsif (not year.match /\d+\ *?(bc|b\.c\.)?/i)
      errors.add(:base, "Not a valid year to center the timeline on")
      return false
    else
      self.center_date = Date.parse('1/1/' + year)
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
      Time.now - 1000.years
    end
  end

  def end_date
    begin
      self.events.order("end_date DESC").first.end_date
    rescue NoMethodError
      Time.now + 20.years
    end
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

  def to_param
    "#{id} #{title}".parameterize
  end
end

