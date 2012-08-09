class CheckinRawText < ActiveRecord::Migration
  def self.up
    add_column :checkins, :raw_text, :text
  end

  def self.down
    remove_column :checkins, :raw_text
  end
end
