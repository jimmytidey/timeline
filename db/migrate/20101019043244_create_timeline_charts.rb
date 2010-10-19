class CreateTimelineCharts < ActiveRecord::Migration
  def self.up
    create_table :timeline_charts do |t|
      t.integer :user_id
      t.string :title
      t.datetime :start
      t.datetime :end
      t.timestamps
    end
  end

  def self.down
    drop_table :timeline_charts
  end
end
