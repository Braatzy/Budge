class NagModePlus < ActiveRecord::Migration
  def self.up
    remove_column :users, :nag_mode
    add_column :users, :nag_mode_id, :integer
    add_column :users, :nag_mode_start_date, :date
    add_column :users, :nag_mode_end_date, :date
    add_column :users, :nag_mode_program_id, :integer
  end

  def self.down
    remove_column :users, :nag_mode_id
    add_column :users, :nag_mode, :integer, :default => 0
    remove_column :users, :nag_mode_start_date
    remove_column :users, :nag_mode_end_date
    remove_column :users, :nag_mode_program_id
  end
end
