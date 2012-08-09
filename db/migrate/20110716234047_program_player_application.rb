class ProgramPlayerApplication < ActiveRecord::Migration
  def self.up
    add_column :program_players, :wants_to_change, :string
    add_column :program_players, :how_badly, :string
    add_column :program_players, :success_statement, :string
  end

  def self.down
    remove_column :program_players, :wants_to_change
    remove_column :program_players, :how_badly
    remove_column :program_players, :success_statement
  end
end
