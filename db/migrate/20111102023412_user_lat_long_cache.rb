class UserLatLongCache < ActiveRecord::Migration
  def self.up
    add_column :users, :last_latitude, :decimal, :precision => 15, :scale => 10
    add_column :users, :last_longitude, :decimal, :precision => 15, :scale => 10
    add_column :users, :lat_long_updated_at, :datetime
  end

  def self.down
    remove_column :users, :last_latitude
    remove_column :users, :last_longitude
    remove_column :users, :lat_long_updated_at
  end
end
