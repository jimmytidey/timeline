class TimelineChart < ActiveRecord::Base
  belongs_to :user
  has_many :events

  attr_accessible :user_id, :title, :start_date, :end_date

  before_validation :check_dates

  validates_presence_of :title
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :user_id
  validates_presence_of :granularity
  validates_numericality_of :user_id

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
