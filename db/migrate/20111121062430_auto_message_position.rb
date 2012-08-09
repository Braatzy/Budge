class AutoMessagePosition < ActiveRecord::Migration
  def self.up
    add_column :program_budges, :action_reveal_type, :integer, :default => 0
  end

  def self.down
    add_column :program_budges, :action_reveal_type
  end
end
