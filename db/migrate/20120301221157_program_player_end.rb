class ProgramPlayerEnd < ActiveRecord::Migration
  def up
    remove_column :program_players, :victorious
    add_column :program_players, :victorious, :boolean
  end

  def down
    remove_column :program_players, :end_victorious
    add_column :program_players, :victorious, :boolean
  end
end
