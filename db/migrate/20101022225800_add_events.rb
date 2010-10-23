class AddEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :title
      t.datetime :start
      t.datetime :end
      t.text :description
      t.string :link
      t.timestamps
    end

    add_index :users, :identifier, :unique => true
  end

  def self.down
    drop_table :events
  end
end
