class ProgramThirdPartyReqs < ActiveRecord::Migration
  def self.up
    add_column :programs, :require_facebook, :boolean, :default => false
    add_column :programs, :require_foursquare, :boolean, :default => false
    add_column :programs, :require_fitbit, :boolean, :default => false
    add_column :programs, :require_withings, :boolean, :default => false    
  end

  def self.down
    remove_column :programs, :require_facebook
    remove_column :programs, :require_foursquare
    remove_column :programs, :require_fitbit
    remove_column :programs, :require_withings
  end
end
