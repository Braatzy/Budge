class ProgramPlayerResponseToken < ActiveRecord::Migration
  def self.up
    add_column :program_players, :response_token, :string
  end

  def self.down
    remove_column :program_players, :response_token
  end
end
