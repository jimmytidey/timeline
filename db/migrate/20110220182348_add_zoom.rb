class AddZoom < ActiveRecord::Migration
  def self.up	
  	add_column :timeline_charts, :intervalPixels, :string, :default => 90
  end

  def self.down
  	remove_column :timeline_charts, :intervalPixels
  end
end
