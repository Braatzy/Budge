class UserCoach < ActiveRecord::Migration
  def self.up
    rename_column :users, :in_beta, :coach
    add_column :oauth_tokens, :primary_token, :boolean, :default => true
    
    OauthToken.update_all(['primary_token = ?', true])
  end

  def self.down
    rename_column :users, :coach, :in_beta
    remove_column :oauth_tokens, :primary_token
  end
end
