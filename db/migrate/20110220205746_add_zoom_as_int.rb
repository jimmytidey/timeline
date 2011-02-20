class AddZoomAsInt < ActiveRecord::Migration
  def self.up	
  	add_column :timeline_charts, :interval_pixels, :integer	, :default => 90
  end

  def self.down
  	remove_column :timeline_charts, :interval_pixels
  end
end
