class RemovePixelCol < ActiveRecord::Migration
  def self.up
	  remove_column :timeline_charts, :interval_pixels
  end

  def self.down
  	  add_column :timeline_charts, :interval_pixels, :integer 
  end
end
