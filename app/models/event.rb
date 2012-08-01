class Event < ActiveRecord::Base
  class EventDateValidator < ActiveModel::Validator
    def validate(record)
      if record.end_date < record.start_date
        record.errors[:end_date] << 'is before the start date'
      end
      record.errors.add(:start_date, "can't be zero. See http://en.wikipedia.org/wiki/0_(year)") if record.start_date.year == 0
      record.errors.add(:end_date, "can't be zero. See http://en.wikipedia.org/wiki/0_(year)") if record.end_date.year == 0
    end
  end

  belongs_to :timeline_chart

  attr_accessible :title, :end_year, :start_year, :start_date, :end_date, :timeline_chart_id, :color, :band, :description

  after_save :mark_timeline_as_updated

  validates_presence_of :title
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :timeline_chart_id

  include ActiveModel::Validations
  validates_with EventDateValidator

  def start_year
    start_date.year
  end

  def end_year
    end_date.year
  end

  def start_date_as_int
    start_date.to_i * 1000
  end

  def end_date_as_int
    end_date.to_i * 1000
  end

  private

  def mark_timeline_as_updated
    tc = self.timeline_chart
    tc.updated_at = Time.now
    tc.save
  end
end

