class RemoveStartAndEndYearsFromTimelineChart < ActiveRecord::Migration
  def self.up
    remove_column :timeline_charts, :start_date, :end_date
  end

  def self.down
    add_column :timeline_charts, :start_date, :datetime
    add_column :timeline_charts, :end_date, :datetime
  end
end
