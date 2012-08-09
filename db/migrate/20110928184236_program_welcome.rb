class ProgramWelcome < ActiveRecord::Migration
  def self.up
    add_column :programs, :welcome_message, :text
  end

  def self.down
    remove_column :programs, :welcome_message
  end
end
