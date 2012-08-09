class SupporterTwitter < ActiveRecord::Migration
  def self.up
    add_column :supporters, :user_twitter_username, :string
  end

  def self.down
    remove_column :supporters, :user_twitter_username
  end
end
