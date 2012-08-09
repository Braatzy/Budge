class BudgeRequestSelfDestruct < ActiveRecord::Migration
  def self.up
    add_column :budge_requests, :closes_at, :datetime
    add_column :user_budges, :budge_request_id, :integer
  end

  def self.down
    remove_column :budge_requests, :closes_at
    remove_column :user_budges, :budge_request_id
  end
end
