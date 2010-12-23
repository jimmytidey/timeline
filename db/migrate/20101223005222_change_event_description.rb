class ChangeEventDescription < ActiveRecord::Migration
  def self.up
  	change_column :events, :description, :text, :limit => 1000
  end

  def self.down
    change_column :events, :description, :string, :limit => 255
  end
end
