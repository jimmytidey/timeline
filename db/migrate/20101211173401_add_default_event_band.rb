class AddDefaultEventBand < ActiveRecord::Migration
  def self.up
  	change_column_default :events, :band, '1'
  end

  def self.down
  	# apparently this can't be undone ! 
  
  end
end
