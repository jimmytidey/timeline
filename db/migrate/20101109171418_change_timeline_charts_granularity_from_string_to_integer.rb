class ChangeTimelineChartsGranularityFromStringToInteger < ActiveRecord::Migration
  def self.up
    change_column :timeline_charts, :granularity, :integer
  end

  def self.down
    change_column :timeline_charts, :granularity, :string
  end
end
