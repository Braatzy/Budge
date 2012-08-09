class OauthAutoPost < ActiveRecord::Migration
  def self.up
    add_column :oauth_tokens, :post_pref_on, :boolean, :default => false
  end

  def self.down
    remove_column :oauth_tokens, :post_pref_off
  end
end
