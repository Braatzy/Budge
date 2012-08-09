class PromptHour < ActiveRecord::Migration
  def self.up
    add_column :prompts, :hour, :integer
  end

  def self.down
    remove_column :prompts, :hour
  end
end
