class EntryPostFlags < ActiveRecord::Migration
  def self.up
    add_column :entries, :post_to_coach, :boolean, :default => false
    add_column :entries, :post_to_twitter, :boolean, :default => false
    add_column :entries, :post_to_facebook, :boolean, :default => false
  end

  def self.down
    remove_column :entries, :post_to_coach
    remove_column :entries, :post_to_twitter
    remove_column :entries, :post_to_facebook
  end
end
