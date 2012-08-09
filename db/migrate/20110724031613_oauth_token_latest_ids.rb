class OauthTokenLatestIds < ActiveRecord::Migration
  def self.up
    add_column :oauth_tokens, :latest_dm_id, :string
  end

  def self.down
    remove_column :oauth_tokens, :latest_dm_id
  end
end
