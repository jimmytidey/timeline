class AddColorToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :color, :string
  end

  def self.down
    remove_column :events, :color
  end
end
