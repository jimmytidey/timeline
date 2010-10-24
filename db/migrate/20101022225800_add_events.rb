class AddEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :title
      t.datetime :start_date
      t.datetime :end_date
      t.integer :timeline_chart_id
      t.timestamps
    end

    add_index :users, :identifier, :unique => true
  end

  def self.down
    drop_table :events
  end
end
