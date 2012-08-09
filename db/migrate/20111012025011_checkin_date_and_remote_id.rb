class CheckinDateAndRemoteId < ActiveRecord::Migration
  def self.up
    add_column :checkins, :user_trait_id, :integer
    add_column :checkins, :date, :date
    add_column :checkins, :remote_id, :string
  end

  def self.down
    remove_column :checkins, :date
    remove_column :checkins, :remote_id
    remove_column :checkins, :updated_via
  end
end
