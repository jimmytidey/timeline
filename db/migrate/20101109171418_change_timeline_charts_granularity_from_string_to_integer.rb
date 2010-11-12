class ChangeTimelineChartsGranularityFromStringToInteger < ActiveRecord::Migration
  def self.up
    remove_column :timeline_charts, :granularity
    add_column :timeline_charts, :zoom, :integer
  end

  def self.down
    remove_column :timeline_charts, :zoom
    add_column :timeline_charts, :granularity, :string
  end
end
