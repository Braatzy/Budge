class ProgramPlayerIndex < ActiveRecord::Migration
  
  # Run Play#delete_duplicate_program_players_and_user_traits before running this migration
  def self.up
    add_index :program_players, [:user_id, :program_id], :name => :user_and_program, :unique => true
    add_index :user_traits, [:user_id, :trait_id], :name => :user_and_trait, :unique => true
  end

  def self.down
    remove_index :program_players, :name => :user_and_program
    remove_index :user_traits, :name => :user_and_trait
  end
end
