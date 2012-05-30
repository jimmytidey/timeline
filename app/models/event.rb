class Event < ActiveRecord::Base
  class EventDateValidator < ActiveModel::Validator
    def validate(record)
      if record.end_date < record.start_date
        record.errors[:end_date] << 'is before the start date'
      end
    end
  end

  belongs_to :timeline_chart

  attr_accessible :title, :end_year, :start_year, :start_date, :end_date, :timeline_chart_id, :color, :band, :description

  after_save :mark_timeline_as_updated

  validates_presence_of :title
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :timeline_chart_id
  validates_numericality_of :start_year
  validates_numericality_of :end_year

  include ActiveModel::Validations
  validates_with EventDateValidator

  def start_year=(year)
    self.start_date = Date.parse('1/1/' + year)
  end

  def end_year=(year)
    self.end_date = Date.parse('1/1/' + year)
  end

  def start_year
    start_date.year
  end

  def end_year
    end_date.year
  end

  def mark_timeline_as_updated
    tc = self.timeline_chart
    tc.updated_at = Time.now
    tc.save
  end
end
