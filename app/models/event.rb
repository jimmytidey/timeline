class Event < ActiveRecord::Base
  belongs_to :timeline_chart

  attr_accessible :title, :end_year, :start_year, :start_date, :end_date, :timeline_chart_id, :color, :band, :description

  before_validation :check_dates
  after_save :mark_timeline_as_updated

  validates_presence_of :title
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :timeline_chart_id

  def update_attributes(attributes)
    st_yr = attributes.delete('start_year')
    end_yr = attributes.delete('end_year')

    if st_yr # This is passed by the form, but not by drag and drop.
      unless st_yr.match /\d+\ *?(bc|b\.c\.)?/i
        errors.add(:base, "Not a valid start year.")
      else
        self.start_date = Date.parse('1/1/' + st_yr)
      end
    end

    if end_yr # This is passed by the form, but not by drag and drop.
      unless end_yr.match /\d+\ *?(bc|b\.c\.)?/i
        errors.add(:base, "Not a valid end year")
      else
        self.end_date = Date.parse('1/1/' + end_yr)
      end
    end
    
    if errors.count > 0 then
      return false
    else
      return super(attributes)
    end
  end

  def start_year
    start_date.year
  end

  def end_year
    end_date.year
  end

  def check_dates
    begin
     # errors[:base] << "The start date can not be before the end date." if start_date > end_date 
      if start_date.year == 0 || end_date.year == 0 then
        errors[:base] << "0 is an invalid year. See http://en.wikipedia.org/wiki/0_(year) for the explanation."
      end
    rescue ArgumentError, NoMethodError
      #End date is probably not set, let validations catch this.
    end
  end

  def mark_timeline_as_updated
    tc = self.timeline_chart
    tc.updated_at = Time.now
    tc.save
  end
end
