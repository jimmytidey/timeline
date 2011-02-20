class RemoveZoom < ActiveRecord::Migration
  def self.up
  	remove_column :timeline_charts, :intervalPixels
  end

  def self.down
 	 add_column :timeline_charts, :intervalPixels, :string, :default => 90
  end
end
