class WakeAndBedUtc < ActiveRecord::Migration
  def up
    add_column :users, :wake_hour_utc, :integer
    add_column :users, :bed_hour_utc, :integer
  end

  def down
    remove_column :users, :wake_hour_utc
    remove_column :users, :bed_hour_utc
  end
end
