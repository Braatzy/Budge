class AutoMessageIncludeLink < ActiveRecord::Migration
  def self.up
    add_column :auto_messages, :include_link, :boolean, :default => true
    add_column :programs, :introduction_message, :text
    add_column :programs, :snooze_message, :text
  end

  def self.down
    remove_column :auto_messages, :include_link
    remove_column :programs, :introduction_message
    remove_column :programs, :snooze_message
  end
end
