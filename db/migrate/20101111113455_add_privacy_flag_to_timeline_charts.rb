class AddPrivacyFlagToTimelineCharts < ActiveRecord::Migration
  def self.up
    add_column :timeline_charts, :private, :boolean
  end

  def self.down
    remove_column :timeline_charts, :private
  end
end
