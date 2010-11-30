class AddCenterDateToTimelineCharts < ActiveRecord::Migration
  def self.up
    add_column :timeline_charts, :center_date, :datetime
  end

  def self.down
    remove_column :timeline_charts, :center_date
  end
end
