class AutoMessageDeliverViaTypeChange < ActiveRecord::Migration
  def self.up
    remove_column :auto_messages, :deliver_via
    add_column :auto_messages, :deliver_via, :integer, :default => 0
  end

  def self.down
    remove_column :auto_messages, :deliver_via
    add_column :auto_messages, :deliver_via, :string
  end
end
