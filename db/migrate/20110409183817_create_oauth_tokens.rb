class CreateOauthTokens < ActiveRecord::Migration
  def self.up
    create_table :oauth_tokens do |t|
      t.integer :user_id
      t.string :site_token
      t.string :site_name
      t.string :token
      t.string :secret
      t.string :remote_name
      t.string :remote_username
      t.string :remote_user_id
      t.text :cached_user_info
      t.datetime :cached_datetime
      t.boolean :working, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :oauth_tokens
  end
end
