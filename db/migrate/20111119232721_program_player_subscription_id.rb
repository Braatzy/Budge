class ProgramPlayerSubscriptionId < ActiveRecord::Migration
  def self.up
    add_column :program_players, :program_coach_subscription_id, :string
  end

  def self.down
    remove_column :program_players, :program_coach_subscription_id
  end
end
