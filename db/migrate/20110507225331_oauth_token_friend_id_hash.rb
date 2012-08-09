class OauthTokenFriendIdHash < ActiveRecord::Migration
  def self.up
    add_column :oauth_tokens, :friend_id_hash, :text
    add_column :oauth_tokens, :friend_id_hash_updated, :datetime
  end

  def self.down
    remove_column :oauth_tokens, :friend_id_hash
    remove_column :oauth_tokens, :friend_id_hash_updated
  end
end
