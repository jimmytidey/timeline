class AddBandToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :band, :integer
  end

  def self.down
    remove_column :events, :band
  end
end
