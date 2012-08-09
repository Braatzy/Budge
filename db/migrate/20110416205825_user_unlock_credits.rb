class UserUnlockCredits < ActiveRecord::Migration
  def self.up
    rename_column :users, :unlock_pack_credits, :level_up_credits
  end

  def self.down
    rename_column :users, :level_up_credits, :unlock_pack_credits
  end
end
