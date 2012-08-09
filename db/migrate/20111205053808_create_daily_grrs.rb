class CreateDailyGrrs < ActiveRecord::Migration
  def self.up
    create_table :daily_grrs do |t|
      t.date :date, :null => false
      t.integer :signups, :default => 0
      t.integer :logins_1day, :default => 0
      t.integer :logins_7day, :default => 0
      t.decimal :revenue, :precision => 10, :scale => 2, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :daily_grrs
  end
end
