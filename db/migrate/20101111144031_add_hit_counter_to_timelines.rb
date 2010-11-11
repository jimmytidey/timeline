class AddHitCounterToTimelines < ActiveRecord::Migration
  def self.up
    add_column :timeline_charts, :hits, :integer
  end

  def self.down
    remove_column :timeline_charts, :hits, :integer
  end
end
