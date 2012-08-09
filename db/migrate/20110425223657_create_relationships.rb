class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
      t.integer :user_id
      t.integer :followed_user_id
      t.boolean :read, :default => false
      t.boolean :auto, :default => false
      t.boolean :invisible, :default => false
      t.boolean :blocked, :default => false
      t.string :from
      t.boolean :found_on_other_network, :default => false
      t.boolean :facebook_friends, :default => false
      t.boolean :twitter_friends, :default => false
      t.boolean :foursquare_friends, :default => false
      t.boolean :referred_signup, :default => false
      t.string :referred_signup_via
      t.integer :referrred_by_budge_request_id
      t.integer :referred_by_budge_id
      t.integer :num_given_budges, :default => 0
      t.integer :num_accepted_budges, :default => 0
      t.integer :num_successful_budges, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :relationships
  end
end
