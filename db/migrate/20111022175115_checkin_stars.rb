class CheckinStars < ActiveRecord::Migration
  def self.up
    add_column :checkins, :stars_for_participation, :decimal, :precision => 11, :scale => 10, :default => 0
    add_column :checkins, :stars_for_mastery, :decimal, :precision => 11, :scale => 10, :default => 0
    add_column :checkins, :stars_for_commenting, :decimal, :precision => 11, :scale => 10, :default => 0
    add_column :checkins, :stars_total, :decimal, :precision => 11, :scale => 10, :default => 0
    
    remove_column :player_budges, :num_stars
    add_column :player_budges, :stars_final, :integer
    add_column :player_budges, :stars_subtotal, :decimal, :precision => 11, :scale => 10, :default => 0
  end

  def self.down
    remove_column :checkins, :stars_for_participation
    remove_column :checkins, :stars_for_mastery
    remove_column :checkins, :stars_for_commenting
    remove_column :checkins, :stars_total
    
    add_column :player_budges, :num_stars, :integer, :default => 0
    remove_column :player_budges, :stars_final
    remove_column :player_budges, :stars_subtotal
  end
end
