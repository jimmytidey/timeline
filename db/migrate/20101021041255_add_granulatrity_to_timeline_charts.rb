class AddGranulatrityToTimelineCharts < ActiveRecord::Migration
  def self.up
    add_column :timeline_charts, :granularity, :string
  end

  def self.down
    remove_column :timeline_charts, :granularity
  end
end
