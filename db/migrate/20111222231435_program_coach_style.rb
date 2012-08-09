class ProgramCoachStyle < ActiveRecord::Migration
  def self.up
    add_column :program_coaches, :coaching_style, :string
    add_column :program_coaches, :num_active_and_unflagged, :integer, :default => 0
    add_column :program_coaches, :num_flagged, :integer, :default => 0
    add_column :program_coaches, :max_active_and_unflagged, :integer, :default => 10
  end

  def self.down
    remove_column :program_coaches, :coaching_style
    remove_column :program_coaches, :num_active_and_unflagged
    remove_column :program_coaches, :num_flagged
    remove_column :program_coaches, :max_active_and_unflagged
  end
end
