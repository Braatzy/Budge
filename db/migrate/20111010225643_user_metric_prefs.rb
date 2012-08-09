class UserMetricPrefs < ActiveRecord::Migration
  def self.up
    add_column :users, :distance_units, :integer, :default => 0
    add_column :users, :weight_units, :integer, :default => 0
    add_column :users, :currency_units, :integer, :default => 0
  end

  def self.down
    remove_column :users, :distance_units
    remove_column :users, :weight_units
    remove_column :users, :currency_units
  end
end
