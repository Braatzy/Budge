class DailyGrrMore < ActiveRecord::Migration
  def self.up
    add_column :daily_grrs, :total_users, :integer, :default => 0
    add_column :daily_grrs, :invitations_sent, :integer, :default => 0
    add_column :daily_grrs, :invitations_redeemed, :integer, :default => 0
    add_column :daily_grrs, :notifications_sent, :integer, :default => 0
    add_column :daily_grrs, :notifications_clicked, :integer, :default => 0
  end

  def self.down
    remove_column :daily_grrs, :total_users
    remove_column :daily_grrs, :invitations_sent
    remove_column :daily_grrs, :invitations_redeemed
    remove_column :daily_grrs, :notifications_sent
    remove_column :daily_grrs, :notifications_clicked
  end
end
