class ChangeTimelineChartsGranularityFromStringToInteger < ActiveRecord::Migration
  def self.up
    remove_column :timeline_charts, :granularity, :string
    add_column :timeline_charts, :granularity, :integer
  end

  def self.down
    remove_column :timeline_charts, :granularity, :integer
    add_column :timeline_charts, :granularity, :string
  end
end
