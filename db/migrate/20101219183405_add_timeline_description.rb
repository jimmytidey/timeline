class AddTimelineDescription < ActiveRecord::Migration
  def self.up
  	add_column :timeline_charts, :description, :string
  end

  def self.down
  	remove_column :timeline_charts, :description
  end
end
