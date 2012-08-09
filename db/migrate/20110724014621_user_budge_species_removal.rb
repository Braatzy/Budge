class UserBudgeSpeciesRemoval < ActiveRecord::Migration
  def self.up
    remove_column :user_budges, :budge_species_token
    remove_column :user_budges, :budge_species_level
  end

  def self.down
    add_column :user_budges, :budge_species_token, :string
    add_column :user_budges, :budge_species_level, :integer
  end
end
